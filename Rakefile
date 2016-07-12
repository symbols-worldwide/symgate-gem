require 'bundler/gem_tasks'
begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec) do |spec|
    spec.pattern = 'test/spec/**/*_spec.rb'
  end
  desc 'Run RSpec integration tests against vagrant symboliser'
  RSpec::Core::RakeTask.new('spec:integration') do |spec|
    spec.pattern = 'test/integration/**/*_spec.rb'
  end

  desc 'Run RSpec code examples with junit output'
  RSpec::Core::RakeTask.new('teamcity:spec') do |spec|
    spec.rspec_opts = '-f RspecJunitFormatter -o .junit/rspec.xml'
    spec.pattern = 'test/spec/**/*_spec.rb'
  end

  desc 'Run RSpec integration tests against vagrant symboliser with junit output'
  RSpec::Core::RakeTask.new('teamcity:spec:integration') do |spec|
    spec.rspec_opts = '-f RspecJunitFormatter -o .junit/integration.xml'
    spec.pattern = 'test/integration/**/*_spec.rb'
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
  task test: [:rubocop, :spec, :'spec:integration']
end

namespace :test do
  task teamcity: 'teamcity:test'
end

namespace :vagrant do
  desc 'Boot the symboliser virtual machine'
  task :up do
    Bundler.with_clean_env do
      system 'bundle install --path vendor/bundle', chdir: 'symboliser-vagrant'
      system 'RUBYLIB= NOEXEC_DISABLE=1 vagrant up',
             chdir: 'symboliser-vagrant'
    end
  end

  desc 'Destroy the symboliser virtual machine'
  task :destroy do
    Bundler.with_clean_env do
      system 'RUBYLIB= NOEXEC_DISABLE=1 vagrant destroy --force',
             chdir: 'symboliser-vagrant'
    end
  end

  desc 'Halt the symboliser virtual machine for later use'
  task :halt do
    system 'RUBYLIB= NOEXEC_DISABLE=1 vagrant halt --force',
           chdir: 'symboliser-vagrant'
  end
end
