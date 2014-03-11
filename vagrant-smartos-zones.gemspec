# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'vagrant/smartos/zones/version'

Gem::Specification.new do |spec|
  spec.name          = "vagrant-smartos-zones"
  spec.version       = Vagrant::Smartos::Zones::VERSION
  spec.authors       = ["Eric Saxby"]
  spec.email         = ["sax@livinginthepast.org"]
  spec.summary       = %q{Manage SmartOS zones in Vagrant}
  spec.description   = %q{Manage SmartOS zones in Vagrant}
  spec.homepage      = "https://github.com/sax/vagrant-smartos-zones"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
end
