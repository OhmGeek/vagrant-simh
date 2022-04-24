require 'log4r'

require 'vagrant/util/platform'

require File.expand_path('base', __dir__)

module VagrantPlugins
  module SimH
    module Driver
      class Version_4 < Base
        def initialize(emulator)
          super(emulator)

          @logger = Log4r::Logger.new('vagrant::provider::simh::simh4')
        end

        def delete; end

        def halt; end

        def read_state; end

        def ssh_port(expected)
          expected
        end

        def start
          command = ['']
          r = raw(*command)

          if r.exit_code != 0
            raise Vagrant::Errors::VBoxManageError,
                  command: command.inspect,
                  stderr: r.stderr
          end
          true
        end

        def suspend; end

        def vm_exists?(_uuid)
          true
        end
      end
    end
  end
end
