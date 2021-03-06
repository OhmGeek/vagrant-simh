begin
  require 'vagrant'
rescue LoadError
  raise 'The Vagrant AWS plugin must be run within Vagrant.'
end

# This is a sanity check to make sure no one is attempting to install
# this into an early Vagrant version.
raise 'The Vagrant SimH plugin is only compatible with Vagrant 1.2+' if Vagrant::VERSION < '1.2.0'

module VagrantPlugins
  module SimH
    class Plugin < Vagrant.plugin('2')
      name 'SimH'
      description <<-DESC
        This plugin installs a provider that allows Vagrant to manage
        machines using SimH.
      DESC

      config('simh', :provider) do
        require_relative 'config'
        Config
      end

      provider('simh', parallel: true) do
        # Setup logging and i18n
        setup_logging

        # Return the provider
        require_relative 'provider'
        Provider
      end

      # This sets up our log level to be whatever VAGRANT_LOG is.
      def self.setup_logging
        require 'log4r'

        level = nil
        begin
          level = Log4r.const_get(ENV['VAGRANT_LOG'].upcase)
        rescue NameError
          # This means that the logging constant wasn't found,
          # which is fine. We just keep `level` as `nil`. But
          # we tell the user.
          level = nil
        end

        # Some constants, such as "true" resolve to booleans, so the
        # above error checking doesn't catch it. This will check to make
        # sure that the log level is an integer, as Log4r requires.
        level = nil unless level.is_a?(Integer)

        # Set the logging level on all "vagrant" namespaced
        # logs as long as we have a valid level.
        if level
          logger = Log4r::Logger.new('vagrant_simh')
          logger.outputters = Log4r::Outputter.stderr
          logger.level = level
          logger = nil
        end
      end
    end
  end
end
