require "pathname"

require "vagrant-simh/plugin"

module VagrantPlugins
  module SimH
    lib_path = Pathname.new(File.expand_path("../vagrant-simh", __FILE__))
    autoload :Action, lib_path.join("action")
    autoload :Errors, lib_path.join("errors")

    # This returns the path to the source of this plugin.
    #
    # @return [Pathname]
    def self.source_root
      @source_root ||= Pathname.new(File.expand_path("../../", __FILE__))
    end
  end
end

begin
  require 'vagrant'
rescue LoadError
  raise 'The Vagrant SimH plugin must be run within Vagrant.'
end

# This is a sanity check to make sure no one is attempting to install
# this into an early Vagrant version.
if Vagrant::VERSION < '1.5.0'
  raise 'The Vagrant SimH plugin is only compatible with newer versions of Vagrant'
end

# make sure base module class defined before loading plugin
require 'vagrant-simh/plugin'