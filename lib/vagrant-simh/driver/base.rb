require 'log4r'
require 'pty'

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

        # Executes a command and returns the raw result object.
        def raw(args, work_dir)
          # Append in the options for subprocess
          cmd_to_run = "#{@simh_path} #{args}"
          @logger.info("Spawning Process: #{cmd_to_run}")
          Dir.chdir(work_dir) do
            job1 = fork do
              # Within the fork process, spawn a PTY (as simh expects this to)
              PTY.spawn(cmd_to_run) do |_reader, _writer, pid|
                Process.wait(pid)
              end
            end
            Process.detach(job1)
          end
        end
      end
    end
  end
end
