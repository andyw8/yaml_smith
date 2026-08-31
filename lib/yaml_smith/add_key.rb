# frozen_string_literal: true

module YamlSmith
  # Adds a key to a YAML file. The key may be a top-level key or a nested
  # path such as `services.0.name`.
  class AddKey < FileCommand
    def call
      document = load_file(@path)
      value = load(@value)

      ensure_mapping(document)
      container, final_key = resolve_container(document)
      raise Error, "key already exists: #{@key}" if container.key?(final_key)

      container[final_key] = value
      write(Psych::Pure.dump(document))
    end
  end
end
