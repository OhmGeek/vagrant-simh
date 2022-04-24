require 'vagrant/action/builder'
require 'log4r'

module VagrantPlugins
  module SimH
    module Action
      # Include the built-in & general modules so we can use them as top level items.
      include Vagrant::Action::Builtin
      include Vagrant::Action::General
      @logger = Log4r::Logger.new('vagrant_simh::action')

      def self.action_up
        Vagrant::Action::Builder.new.tap do |b|
          # TODO here we load the associated actions from the action/* based on simh startup.
        end
      end
    end
  end
end