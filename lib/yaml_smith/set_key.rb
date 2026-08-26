# frozen_string_literal: true

module YamlSmith
  # Sets a top-level key in a YAML file, adding or replacing it.
  class SetKey < FileCommand
    def call
      document = load_file(@path)
      value = load(@value)

      ensure_mapping(document)
      document[@key] = value
      write(Psych::Pure.dump(document))
    end
  end
end
