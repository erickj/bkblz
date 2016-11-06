# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bkblz/version'

Gem::Specification.new do |s|
  s.name          = "bkblz"
  s.version       = Bkblz::VERSION
  s.authors       = ["Erick Johnson"]
  s.email         = ["erick@vos.io"]

  s.summary       = "Bkblz GEM for the Backblaze B2 API. https://www.backblaze.com/b2/docs/"
  s.description   = s.description
  s.homepage      = "https://github.com/erickj/bkblz"
  s.license       = "MIT"

  s.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  s.require_paths = ["lib"]

  s.add_dependency "thor", "~> 0.19"

  s.add_development_dependency "bundler", "~> 1.13"
  s.add_development_dependency "rake", "~> 10.0"
  s.add_development_dependency "rspec", "~> 3.0"
end
