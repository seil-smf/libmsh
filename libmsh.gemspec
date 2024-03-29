# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'libmsh/version'

Gem::Specification.new do |spec|
  spec.name          = "libmsh"
  spec.version       = Libmsh::VERSION
  spec.authors       = ["Internet Initiative Japan, Inc."]
  spec.summary       = "SACM API client library."
  spec.description   = "library for SACM API client."
  spec.homepage      = ""
  spec.license       = "IIJ"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"

  spec.add_dependency 'faraday'
end
