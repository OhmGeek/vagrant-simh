require 'log4r'

module VagrantPlugins
    module SimH
        module Action
            class BootSimH
                def initialize(app, _env)
                    @logger = Log4r::Logger.new('vagrant_simh::action::boot_simh')
                    @app = app
                end

                def call(env)
                    env[:ui].info("Starting SimH")
                    exec("/bin/ls")
                end
            end
        end
    end
end
