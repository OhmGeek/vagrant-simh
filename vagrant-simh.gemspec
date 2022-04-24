# -*- encoding: utf-8 -*-
# frozen_string_literal: true

Gem::Specification.new do |s|
  s.authors       = ['Ryan Collins']
  s.email         = ['']
  s.license       = 'MIT'
  s.description   = %q{SimH provider for Vagrant.}
  s.summary       = %q{SimH provider for Vagrant.}
  s.homepage      = 'http://ohmgeek.co.uk'
  s.metadata      = {
    "source_code_uri" => 'http://ohmgeek.co.uk',
  }

  s.files         = Dir.glob("{lib,locales}/**/*") + %w(README.md)
  s.executables   = Dir.glob("bin/*.*").map{ |f| File.basename(f) }
  s.test_files    = Dir.glob("{test,spec,features}/**/*.*")
  s.name          = 'vagrant-simh'
  s.require_paths = ['lib']
  s.version       = '0.0.1'

  s.add_development_dependency "rspec-core", ">= 3.5"
  s.add_development_dependency "rspec-expectations", ">= 3.5"
  s.add_development_dependency "rspec-mocks", ">= 3.5"

  s.add_runtime_dependency 'rexml'

  # Make sure to allow use of the same version as Vagrant by being less specific
  s.add_runtime_dependency 'nokogiri', '~> 1.6'

  s.add_development_dependency 'rake'
end