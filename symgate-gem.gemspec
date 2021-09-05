lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'symgate'

Gem::Specification.new do |spec|
  spec.name          = 'symgate'
  spec.version       = Symgate::VERSION
  spec.authors       = ['Simon Detheridge', 'Tim Down', 'Stu Wright']
  spec.email         = ['tim@widgit.com']
  spec.license       = 'Apache-2.0'
  spec.required_ruby_version = '>= 2.1'

  spec.summary       = "Wrapper around Widgit's Symgate SOAP symboliser"
  spec.homepage      = 'https://github.com/symbols-worldwide/symgate-gem'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f|
    f.match(%r{^(test|spec|features)/})
  }
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 2.2'
  spec.add_development_dependency 'codecov', '~> 0.1.16'
  spec.add_development_dependency 'mysql2', '~> 0.5.3'
  spec.add_development_dependency 'rack', '~> 2.2'
  spec.add_development_dependency 'rake', '~> 12.0'
  spec.add_development_dependency 'rspec', '~> 3.9.0'
  spec.add_development_dependency 'rspec_junit_formatter', '~> 0.4.1'
  spec.add_development_dependency 'rubocop', '~> 0.57.0'
  spec.add_development_dependency 'rubocop-junit-formatter', '~> 0.1.4'
  spec.add_development_dependency 'simplecov', '~> 0.17.0'
  spec.add_development_dependency 'simplecov-teamcity-summary', '~> 1.0.0'

  spec.add_dependency 'savon', '~> 2.12.0'
  spec.add_dependency 'tryit', '~> 0.0.1'
end
