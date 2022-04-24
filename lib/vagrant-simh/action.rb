require 'vagrant/action/builder'
require 'log4r'

module VagrantPlugins
  module SimH
    module Action
      action_root = Pathname.new(File.expand_path('../action', __FILE__))
      autoload :BootSimH, action_root.join('boot_simh')
      autoload :ReadState, action_root.join('read_state')

      # Include the built-in & general modules so we can use them as top level items.
      include Vagrant::Action::Builtin
      include Vagrant::Action::General
      @logger = Log4r::Logger.new('vagrant_simh::action')

      def self.action_up
        Vagrant::Action::Builder.new.tap do |b|
          # Vagrant up just boots SimH as is. No extra complexity!
          b.use BootSimH
        end
      end

      def self.action_read_state
        Vagrant::Action::Builder.new.tap do |b|
          b.use ReadState
        end
      end
    end

  end
end