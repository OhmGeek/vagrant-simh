require 'log4r'

require 'vagrant/util/busy'
require 'vagrant/util/platform'
require 'vagrant/util/retryable'
require 'vagrant/util/subprocess'
require 'vagrant/util/which'

module VagrantPlugins
  module SimH
    module Driver
      # Base class for all SimH drivers.
      #
      # This class provides useful tools for things such as executing
      # VBoxManage and handling SIGINTs and so on.
      # TODO: use provided SimH emulator
      class Base
        # Include this so we can use `Subprocess` more easily.
        include Vagrant::Util::Retryable

        def initialize(emulator)
          @logger = Log4r::Logger.new('vagrant::provider::simh::base')

          # This flag is used to keep track of interrupted state (SIGINT)
          @interrupted = false

          if Vagrant::Util::Platform.windows? || Vagrant::Util::Platform.cygwin?
            @logger.debug('Windows, checking for SimH emulator on PATH first')
            @simh_path = Vagrant::Util::Which.which(emulator)

            # On Windows, we use the SIMH_INSTALL_PATH environmental
            # variable to find the SimH emulator.
            if !@simh_path && ENV.key?('SIMH_INSTALL_PATH')
              @logger.debug('Windows. Trying SIMH_INSTALL_PATH for provided SimH emulator')

              # Get the path.
              path = ENV['SIMH_INSTALL_PATH']
              @logger.debug("SIMH_INSTALL_PATH value: #{path}")

              # There can actually be multiple paths in here, so we need to
              # split by the separator ";" and see which is a good one.
              path.split(';').each do |single|
                # Make sure it ends with a \
                single += '\\' unless single.end_with?('\\')

                # If the executable exists, then set it as the main path
                # and break out
                simh_emulator = "#{single}#{emulator}"
                if File.file?(simh_emulator)
                  @simh_path = Vagrant::Util::Platform.cygwin_windows_path(simh_emulator)
                  break
                end
              end
            end

          elsif Vagrant::Util::Platform.wsl?
            unless Vagrant::Util::Platform.wsl_windows_access?
              @logger.error('No user Windows access defined for the Windows Subsystem for Linux. This is required for SimH.')
              raise Vagrant::Errors::WSLVirtualBoxWindowsAccessError
            end
            @logger.debug("Linux platform detected but executing within WSL. Locating #{emulator}.")
            @simh_path = Vagrant::Util::Which.which(emulator)
          end

          # Fall back to hoping for the PATH to work out
          @simh_path ||= emulator
          @logger.info("#{emulator} path: #{@simh_path}")
        end

        # Deletes the virtual machine references by this driver.
        def delete; end

        # Halts the virtual machine (pulls the plug).
        def halt; end

        # Returns the current state of this VM.
        #
        # @return [Symbol]
        def read_state; end

        # Reads the SSH port of this VM.
        #
        # @param [Integer] expected Expected guest port of SSH.
        def ssh_port(expected); end

        # Starts the virtual machine.
        def start(data_dir); end

        # Suspend the virtual machine.
        def suspend; end

        # Checks if a VM with the given UUID exists.
        #
        # @return [Boolean]
        def vm_exists?(uuid); end

        # Execute the given subcommand for VBoxManage and return the output.
        def execute(*command, &block)
          # Get the options hash if it exists
          opts = {}
          opts = command.pop if command.last.is_a?(Hash)

          # Execute the command
          r = raw(*command, &block)

          # If the command was a failure, then raise an exception that is
          # nicely handled by Vagrant.
          if r.exit_code != 0
            if @interrupted
              @logger.info('Exit code != 0, but interrupted. Ignoring.')
            elsif r.exit_code == 126
              # This exit code happens if SimH emulator is on the PATH,
              # but another executable it tries to execute is missing.
              # This is usually indicative of a corrupted SimH install.
              raise Vagrant::Errors::VBoxManageNotFoundError
            else
              errored = true
            end
          end

          # TODO: raise custom exception
          # If there was an error running VBoxManage, show the error and the
          # output.
          if errored
            raise Vagrant::Errors::VBoxManageError,
                  command: command.inspect,
                  stderr: r.stderr,
                  stdout: r.stdout
          end

          # Return the output, making sure to replace any Windows-style
          # newlines with Unix-style.
          r.stdout.gsub("\r\n", "\n")
        end

        # Executes a command and returns the raw result object.
        def raw(*command, &block)
          int_callback = lambda do
            @interrupted = true

            # We have to execute this in a thread due to trap contexts
            # and locks.
            Thread.new { @logger.info('Interrupted.') }.join
          end

          # Append in the options for subprocess
          command << { notify: %i[stdout stderr] }

          Vagrant::Util::Busy.busy(int_callback) do
            Vagrant::Util::Subprocess.execute(@simh_path, *command, &block)
          end
        rescue Vagrant::Util::Subprocess::LaunchError => e
          raise Vagrant::Errors::VBoxManageLaunchError,
                message: e.to_s
        end
      end
    end
  end
end
