# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'prophecy/version'

Gem::Specification.new do |spec|
  spec.name          = "prophecy"
  spec.version       = Prophecy::VERSION
  spec.authors       = ["Gambhiro"]
  spec.email         = ["gambhiro@ratanagiri.org.uk"]
  spec.summary       = %q{Book boilerplate for generating PDF, EPUB and MOBI}
  spec.description   = %q{Book boilerplate to generate books as EPUB,
    MOBI, and PDF from simple Markdown text files. Or from HTML. Or from
    LaTeX. Or mixed.}
  spec.homepage      = "http://profound-labs.github.io/projects/prophecy/"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = [ 'prophecy', ]
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "cucumber"
  spec.add_development_dependency "aruba"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "pry-debugger"
  spec.add_development_dependency "awesome_print"

  spec.add_runtime_dependency "compass", ">= 0.12.2"
  spec.add_runtime_dependency "kramdown", ">= 1.2.0"
  spec.add_runtime_dependency "nokogiri", ">= 1.6.0"
  spec.add_runtime_dependency "roman-numerals", ">= 0.3.0"
  spec.add_runtime_dependency "mime-types", ">= 1.25"
  spec.add_runtime_dependency "thor", "~> 0.18"

end
