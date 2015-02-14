# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'vagrant/smartos/zones/version'

Gem::Specification.new do |spec|
  spec.name          = 'vagrant-smartos-zones'
  spec.version       = Vagrant::Smartos::Zones::VERSION
  spec.authors       = ['Eric Saxby']
  spec.email         = ['sax@livinginthepast.org']
  spec.summary       = 'Manage SmartOS zones in Vagrant'
  spec.description   = 'Manage SmartOS zones in Vagrant'
  spec.homepage      = 'https://github.com/vagrant-smartos/vagrant-smartos-zones'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(/^bin\//) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(/^(test|spec|features)\//)
  spec.require_paths = ['lib']

  spec.add_dependency 'netaddr'

  spec.add_development_dependency 'bundler', '~> 1.5'
  spec.add_development_dependency 'pry-nav'
  spec.add_development_dependency 'rake'
end
