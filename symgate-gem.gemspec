# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'symgate'

Gem::Specification.new do |spec|
  spec.name          = 'symgate'
  spec.version       = Symgate::VERSION
  spec.authors       = ['Simon Detheridge']
  spec.email         = ['simon@widgit.com']

  spec.summary       = "Wrapper around Widgit's Symgate SOAP symboliser"
  spec.homepage      = 'https://github.com/symbols-worldwide/symgate'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f|
    f.match(%r{^(test|spec|features)/})
  }
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.9'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.4.0'
  spec.add_development_dependency 'rubocop', '~> 0.41.1'
  spec.add_development_dependency 'rspec_junit_formatter', '~> 0.2.3'
  spec.add_development_dependency 'rubocop-junit-formatter', '~> 0.1.3'
  spec.add_development_dependency 'rack', '~> 1.6.4'

  spec.add_dependency 'savon', '~> 2.11.0'
end
