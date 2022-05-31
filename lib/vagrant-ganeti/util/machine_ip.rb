module VagrantPlugins
  module GANETI
    module Util
      def ip_of_machine(machine)
        return nil if machine.id.nil?

        config     = env[:machine].provider_config.get_config() 
        client = VagrantPlugins::GANETI::Util::GanetiClient.new(config.cluster,config.rapi_user,config.rapi_pass)
        
        # Read the DNS info by default
        host = machine.id
        ip_nics = client.get_ip()
        if !ip_nics.nil?
          host = ip_nics
        end
        return host
      end
    end
  end
end
