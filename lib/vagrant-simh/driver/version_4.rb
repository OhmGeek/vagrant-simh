require 'log4r'

require 'vagrant/util/platform'

require File.expand_path('base', __dir__)

module VagrantPlugins
  module SimH
    module Driver
      class Version_4 < Base
        def initialize(emulator)
          super(emulator)
          @emulator = emulator
          @logger = Log4r::Logger.new('vagrant::provider::simh::simh4')
        end

        def delete; end

        def halt; end

        def read_state; end

        def ssh_port(expected)
          expected
        end

        def start(data_dir)
          # Use the ini file of the emulator
          arg = "#{data_dir}/vax780.ini > output.log"
          raw(arg, data_dir)
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
