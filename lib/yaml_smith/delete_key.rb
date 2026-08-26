# frozen_string_literal: true

module YamlSmith
  # Deletes a top-level key from a YAML file.
  class DeleteKey < FileCommand
    def call
      document = load_file(@path)

      ensure_mapping(document)
      raise Error, "key does not exist: #{@key}" unless document.key?(@key)

      document.delete(@key)
      write(Psych::Pure.dump(document))
    end
  end
end
