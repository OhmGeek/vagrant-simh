require 'vagrant'

module VagrantPlugins
  module SimH
    class Config < Vagrant.plugin('2', :config)
    end
  end
end
