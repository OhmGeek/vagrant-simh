# Vagrant SimH Plugin
## Roughly how this will work:
Given:
- SimH emulator type to use e.g. `vax780`
- A location of a box (just an archive containing the simh ini file, and subsequent dependencies including disks)
  - Note: we can later support templating here (so users can fill in the gaps as needed for example specifying disks/etc)
- The location of the simh emulator binaries (defaults to the user path, but can use the checkout dir from the SimH 4 repo)

When:
- We execute vagrant up:
  - Download the archive
  - Extract the archive to the current directory
  - Find the location of the simh binaries
  - Run the simh binary within the correct directory to start up the emulator 

- We execute vagrant telnet (since some older emulators won't support ssh):
  - We invoke telnet to telnet into the SimH instance
  - We then give the user a telnet shell to play around as required.

## Config:
- simh.version
  - For now, we only support '4'.
  - Later we can add support for SimH '3' stream (binary locations are different)

- simh.emulator
  - This defines the simh binary for example 'vax780' for a VAX 11/780 emulator

