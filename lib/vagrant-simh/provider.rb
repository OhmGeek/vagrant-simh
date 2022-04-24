require "log4r"
require "vagrant"

module VagrantPlugins
  module SimH
    class Provider < Vagrant.plugin("2", :provider)
      def initialize(machine)
        @machine = machine
      end

      def action(name)
        # Attempt to get the action method from the Action class if it
        # exists, otherwise return nil to show that we don't support the
        # given action.
        action_method = "action_#{name}"
        return Action.send(action_method) if Action.respond_to?(action_method)
      end

      def state
        env = @machine.action("read_state", lock: false)

        state_id = env[:machine_state_id]

        # TODO fetch these from configuration.
        short = "blah"
        long = "blah"
        Vagrant::MachineState.new(state_id, short, long)
      end
    end
  end
end