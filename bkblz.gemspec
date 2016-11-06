# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bkblz/version'

Gem::Specification.new do |spec|
  spec.name          = "bkblz"
  spec.version       = Bkblz::VERSION
  spec.authors       = ["Erick Johnson"]
  spec.email         = ["erick@vos.io"]

  spec.summary       = "Bkblz GEM for the Backblaze B2 API. https://www.backblaze.com/b2/docs/"
  spec.description   = spec.description
  spec.homepage      = "https://github.com/erickj/bkblz"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
