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
	    
	    info = {
	    '__version__'    => 1    , 
	    'os_type' => config.os_type ,              
	    'disk_template' => config.disk_template ,
	    'disks' => config.disks ,
	    'instance_name' => config.instance_name ,
	    'mode' => config.mode ,        
	    'nics'   => config.nics
	     }
	    info['pnode'] = config.pnode if not config.pnode.nil?
	    info['snode'] = config.snode if not config.snode.nil?
            info['iallocator'] = config.iallocator if not config.iallocator.nil?
            info['beparams'] = {}
	    info['beparams']['memory'] = config.memory if not config.memory.nil?
	    info['beparams']['vcpus'] = config.vcpus if not config.vcpus.nil?    
	



	    @logger.info("Connecting to GANETI...")
            #Call  ganeti_client ruby wrapper
	    client = VagrantPlugins::GANETI::Util::GanetiClient.new(config.cluster,config.rapi_user,config.rapi_pass,info)
	    env[:ganeti_compute] = client
	    @app.call(env)
        end
       end
      end #Action
  end #ganeti
end #VagrantPlugin
