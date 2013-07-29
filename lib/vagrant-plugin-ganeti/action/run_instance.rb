require "log4r"

module VagrantPlugins
  module GANETI
    module Action
      # "unlink" vagrant and the managed server
      class RunInstance

        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant_ganeti::action::remove_instance")
        end

        def call(env)
            config     = env[:machine].provider_config.get_config()
	    client = env[:ganeti_compute]
           # Launch!
            env[:ui].info(I18n.t("vagrant_ganeti.launching_instance"))
            env[:ui].info(" -- Username: #{config.rapi_user}")
            env[:ui].info(" -- OS NAME: #{config.os_type}")
            env[:ui].info(" -- Instance NAME: #{config.instance_name}")
            env[:ui].info(" -- Host: #{config.cluster}")
            env[:ui].info(" -- Primary Noode #{config.pnode}") 
            env[:ui].info(" -- Disk Template: #{config.disk_template}")
            env[:ui].info(" -- Disks #{config.disks}") 
            env[:ui].info(" -- Network Configurations: #{config.nics}") 
            env[:ui].info(" -- Version : #{config.version }") if config.version 

            createjob = client.instance_create()
	    env[:ui].info( "New Job Created #{createjob}.")
 	    env[:ui].info( "Creating Instance")
	    env[:ui].info( "This might take few minutes.....")
	    puts env[:ganeti_compute]


	    while true
		if  client.is_job_ready(createjob) == "error"
			env[:ui].info("Error Creating instance")
			break
		elsif client.is_job_ready(createjob) == "running"
			#Waiting for the message to succeed
			sleep(15)
		elsif client.is_job_ready(createjob) == "success" or  client.is_job_ready(createjob) == "already_exists"
	    		env[:ui].info( "Instance sucessfully Created.")
 	    		env[:ui].info( "Booting up the Instance.")
            		bootinstancejob = client.start_instance()
			sleep(3)
		      	if client.is_job_ready(bootinstancejob) == "success" 
				env[:machine].id = client.info['nics'][0]['ip']
			        env[:ui].info( "#{ env[:machine].id}")
				env[:ui].info("Instance Started Sucessfully")
		        else
			 	env[:ui].info("Error Staring Instance")
                        end 
			break
		end
            end

          @app.call(env)
        end
      end
    end
  end
end
