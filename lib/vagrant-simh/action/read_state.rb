require "log4r"
require 'vagrant/machine_state'

module VagrantPlugins
    module SimH
        module Action
            class ReadState
                def initialize(app, env)
                    @app = app
                    @logger = Log4r::Logger.new("vagrant_simh::action::read_state")
                end

                def call(env)
                    env[:machine_state_id] = read_state(env[:machine])
                    @app.call(env)
                end

                def read_state(machine)
                    return :not_created if machine.id.nil?

                    # Find the machine
                    # TODO look up the pid and use that to define whether server is running.
                    
                    return MachineState.new(":running", "running", "running")
                end
            end
        end
    end
end