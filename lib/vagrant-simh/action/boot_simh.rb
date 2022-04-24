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
                    fork {
                        exec("/home/ryan/Documents/dev/simh/BIN/vax780")
                    }
                    env[:ui].info("SimH started")
                    @app.call(env)
                end
            end
        end
    end
end
