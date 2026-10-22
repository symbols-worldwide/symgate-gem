require 'yaml'

class SymboliserConfig
  def self.config(directory = __dir__)
    # Load symboliser.yml and override it with local.yml when that file is present.
    config = YAML.load_file(File.join(directory, 'symboliser.yml'))
    local_file = File.join(directory, 'local.yml')
    config = deep_merge(config, YAML.load_file(local_file)) if File.exist?(local_file)
    config
  end

  def self.deep_merge(base, overrides)
    base.merge(overrides) do |_key, original, override|
      if original.is_a?(Hash) && override.is_a?(Hash)
        deep_merge(original, override)
      else
        override
      end
    end
  end
  private_class_method :deep_merge
end
