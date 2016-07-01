require 'bundler/gem_tasks'
begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec) do |spec|
    spec.pattern = 'test/spec/**/*_spec.rb'
  end

  desc 'Run RSpec code examples with junit output'
  RSpec::Core::RakeTask.new('teamcity:spec') do |spec|
    spec.rspec_opts = '-f RspecJunitFormatter -o .junit/rspec.xml'
    spec.pattern = 'test/spec/**/*_spec.rb'
  end
rescue LoadError
  $stderr.puts 'Unable to find rspec gem'
end

desc 'Runs the rubocop linting tool'
task :rubocop do
  raise 'rubocop failed' unless system 'bundle exec rubocop'
end

desc 'Run all tests'
task test: [:rubocop, :spec]

namespace :teamcity do
  desc 'Runs rubocop with junit output'
  task :rubocop do
    raise 'rubocop failed' unless system 'bundle exec rubocop ' \
      '--no-color --require rubocop/formatter/junit_formatter ' \
      '--format RuboCop::Formatter::JUnitFormatter --out .junit/rubocop.xml'
  end

  desc 'Run all tests with junit output'
  task test: [:rubocop, :spec]
end

namespace :test do
  task teamcity: 'teamcity:test'
end
