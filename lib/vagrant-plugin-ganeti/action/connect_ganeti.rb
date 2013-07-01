require 'rubygems'
require 'uri'
require 'net/http'
require 'net/https'
require 'base64'
require 'json'
require 'log4r'

module VagrantPlugins
  module GANETI
    module Action
      # This action connects to Ganeti, verifies credentials start the instance.
      class ConnectGANETI
        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant_ganeti::action::connect_ganeti")
        end

        def call(env)
            config     = env[:machine].provider_config.get_config()

            @logger.info("Connecting to GANETI...")
            #Call  ganeti_client ruby wrapper
	    client = GanetiClient.new(config.host,config.username,config.password)
	    #client = GanetiClient.new("https://10.1.0.135:5080" ,"gsoc","v0fdYnVs")

	    info = {
	    '__version__'    => 1    , 
	    'os_type' => config.os_name,              
	    'disk_template' => config.disk_template,
	    'disks' => config.disks,
	    'instance_name' => config.instance_name,
	    'mode' => config.mode,        
	    'nics'   => config.nics,
	    'pnode' => config.pnode
	     }

            # Launch!
            env[:ui].info(I18n.t("vagrant_ganeti.launching_instance"))
            env[:ui].info(" -- Username: #{username}")
            env[:ui].info(" -- OS NAME: #{os_name}")
            env[:ui].info(" -- Instance NAME: #{instance_name}")
            env[:ui].info(" -- Host: #{host}")
            env[:ui].info(" -- Primary Noode #{pnode}") 
            env[:ui].info(" -- Disk Template: #{disk_template}")
            env[:ui].info(" -- Disks #{disks}") 
            env[:ui].info(" -- Network Configurations: #{nics}") 
            env[:ui].info(" -- Version : #{version }") if version 


            client.instance_create(info)
            client.start_instance(info)
	    #do it after 100 seconds
	    puts "This might take few minutes....."
	    sleep(5)
	    puts "Ready" if client.isready(info)
	    @app.call(env)
        end
      end
      class GanetiClient
		attr_accessor :host, :username, :password, :version
		
		def initialize(host, username, password)
		    self.host = host
		    self.username = username
		    self.password = password
		    self.version = self.version_get
		    puts self.version
		end

	
		def instance_create(info, dry_run = 0)
		    
		    
		    url = get_url("instances")
		    body = info.to_json
		    response_body = send_request("POST", url, body)
		
		    return response_body
		end

		def isready(info)
		    url = get_url("instances/#{info['instance_name']}")
		    puts url
		    response_body = send_request("GET", url)
		    
		    return response_body["status"]== "running" ? true : false
		end

		def start_instance(info)
		    url = get_url("instances/#{info['instance_name']}/startup")
		    puts url
		    response_body = send_request("PUT", url)
		    return response_body
		end

		def version_get
		    url = get_url("version")
		    response_body = send_request("GET", url)
		    
		    return response_body
		end
	
		def authenticate(username, password)
		    basic = Base64.encode64("#{username}:#{password}").strip
		    return "Basic #{basic}"
		end
	    
	
		def get_url(path, params = nil)
		    param_string = ""

		    if params
		        params.each do |key, value|
		            if value.kind_of?(Array)
		                value.each do |svalue|
		                    param_string += "#{key}=#{svalue}&"
		                end
		            else
		                param_string += "#{key}=#{value}&"
		            end
		        end
		    end

		     url =  (self.version)? "/#{self.version}/#{path}?#{param_string}" : "/#{path}?#{param_string}"
	  
		    return url.chop
		end

	
		def send_request(method, url, body = nil, headers = {}) 
		   uri = URI.parse(host)

		   http = Net::HTTP.new(uri.host, uri.port)
		   http.use_ssl = true
		   http.verify_mode = OpenSSL::SSL::VERIFY_NONE
		   headers['User-Agent'] = 'Ruby Ganeti RAPI Client'
		   headers['Content-Type'] = 'application/json'
		   headers['Authorization']= authenticate(self.username, self.password)
		  
		   begin
		       response = http.send_request(method, url, body, headers)
		      # response = http.send_request("GET",url)
		       puts body
		       puts response
		       puts response.body
		   rescue => e
		        puts "Error sending request"
		        puts e.message
			       
		    else
		        case response
		        when Net::HTTPSuccess
		            parse_response(response.body.strip)
		        else
		            response.instance_eval { class << self; attr_accessor :body_parsed; end }
		            begin 
		                response.body_parsed = parse_response(response.body) 
		            rescue
		                # raises  exception corresponding to http error Net::XXX
		                puts response.error! 
		            end
		        end
		    end
		end


		def parse_response(response_body)
		    # adding workaround becouse Google seems to operate on 'non-strict' JSON format
		    # http://code.google.com/p/ganeti/issues/detail?id=117
		    begin
		        response_body = JSON.parse(response_body)
		    rescue
		        response_body = JSON.parse('['+response_body+']').first
		    end

		    return response_body
		end
	end #Class GanetiClient
      end #Action
  end #ganeti
end #VagrantPlugin
