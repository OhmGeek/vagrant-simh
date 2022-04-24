require 'log4r'
require 'vagrant'

module VagrantPlugins
  module SimH
    class Provider < Vagrant.plugin('2', :provider)
      attr_reader :driver
      
      def initialize(machine)
        @machine = machine
        # TODO : Allow the user to change exactly what emu to use
        @driver = Driver::Version_4.new('vax780')
      end

      def action(name)
        # Attempt to get the action method from the Action class if it
        # exists, otherwise return nil to show that we don't support the
        # given action.
        action_method = "action_#{name}"
        return Action.send(action_method) if Action.respond_to?(action_method)
      end

      def state
        env = @machine.action('read_state', lock: false)

        state_id = env[:machine_state_id]

        # TODO: fetch these from configuration.
        short = 'blah'
        long = 'blah'
        Vagrant::MachineState.new(state_id, short, long)
      end
    end

    module Driver
      autoload :Version_4, File.expand_path('driver/version_4', __dir__)
    end
  end
end
