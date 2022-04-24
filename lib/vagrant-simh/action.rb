require 'vagrant/action/builder'
require 'log4r'

module VagrantPlugins
  module SimH
    module Action
      action_root = Pathname.new(File.expand_path('../action', __FILE__))
      autoload :BootSimH, action_root.join('boot_simh')


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
    end
  end
end