require 'savon'
require 'tmpdir'
require_relative 'spec_helper'

RSpec.describe(SymboliserConfig) do
  def write_config(directory, name, values)
    File.write(File.join(directory, name), YAML.dump(values))
  end

  it 'returns the symboliser settings when no local file is present' do
    Dir.mktmpdir do |directory|
      write_config(directory, 'symboliser.yml', 'wsdl' => 'http://example.test/symboliser.wsdl')

      expect(SymboliserConfig.config(directory)).to eq('wsdl' => 'http://example.test/symboliser.wsdl')
    end
  end

  it 'overrides nested settings from local.yml' do
    Dir.mktmpdir do |directory|
      write_config(
        directory,
        'symboliser.yml',
        'wsdl' => 'http://example.test/symboliser.wsdl',
        'database' => { 'host' => '127.0.0.1', 'name' => 'symboliser' }
      )
      write_config(
        directory,
        'local.yml',
        'wsdl' => 'http://symboliser.test/symboliser.wsdl',
        'database' => { 'host' => 'db.example.test' }
      )

      expect(SymboliserConfig.config(directory)).to eq(
        'wsdl' => 'http://symboliser.test/symboliser.wsdl',
        'database' => { 'host' => 'db.example.test', 'name' => 'symboliser' }
      )
    end
  end
end
