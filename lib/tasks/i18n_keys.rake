# frozen_string_literal: true

namespace :i18n_keys do
  desc "Generate config/locales/i18n_keys.yml from config/locales/en.yml"
  task generate: :environment do
    require "yaml"
    locale_dir = Rails.root.join("config", "locales")
    source_path = locale_dir.join("en.yml")
    target_path = locale_dir.join("i18n_keys.yml")

    raise "Source locale file not found: #{source_path}" unless File.exist?(source_path)

    source = YAML.load_file(source_path)
    unless source.is_a?(Hash) && source.keys.size == 1
      raise "Expected source locale file to contain a single top-level locale key"
    end

    language, data = source.first
    generated = { "i18n_keys" => map_values(data) }

    File.write(target_path, generated.to_yaml(line_width: -1))
    puts "Generated #{target_path}"
  end

  def map_values(node, path = [])
    case node
    when Hash
      node.each_with_object({}) do |(key, value), memo|
        memo[key.to_s] = map_values(value, path + [key.to_s])
      end
    when Array
      node.map { |entry| map_values(entry, path) }
    else
      path.join(".")
    end
  end
end
