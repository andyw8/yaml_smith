# frozen_string_literal: true

module YamlSmith
  # Adds a top-level key to a YAML file.
  class AddKey < FileCommand
    def call
      document = load_file(@path)
      value = load(@value)

      ensure_mapping(document)
      raise Error, "key already exists: #{@key}" if document.key?(@key)

      document[@key] = value
      write(Psych::Pure.dump(document))
    end
  end
end
