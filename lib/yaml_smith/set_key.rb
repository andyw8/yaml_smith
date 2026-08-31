# frozen_string_literal: true

module YamlSmith
  # Sets a key in a YAML file, adding or replacing it. The key may be a
  # top-level key or a nested path such as `services.0.name`.
  class SetKey < FileCommand
    def call
      document = load_file(@path)
      value = load(@value)

      ensure_mapping(document)
      container, final_key = resolve_container(document)
      container[final_key] = value
      write(Psych::Pure.dump(document))
    end
  end
end
