class SymboliserConfig
  def self.config
    # Loading config from symboliser.yml and override with settings from local.yml
    config = YAML.load_file(File.join(__dir__, 'symboliser.yml'))
    local_file = File.join(__dir__, 'local.yml')
    if File.exist?(local_file)
      config.deep_merge!(YAML.load_file(local_file))
    end
    config
  end
end
