# frozen_string_literal: true

module YamlSmith
  # Deletes a uniquely matching key from anywhere in a YAML file.
  class DeleteKey < FileCommand
    def call
      document = load_file(@path)

      ensure_mapping(document)
      matches = find_matches(document)
      raise Error, "key does not exist: #{@key}" if matches.empty?
      raise Error, "key is not unique: #{@key}" if matches.length > 1

      matches.first.delete(@key)
      write(Psych::Pure.dump(document))
    end

    private

    def find_matches(value, matches = [])
      case value
      when Psych::Pure::LoadedHash
        matches << value if value.key?(@key)
        value.each_value { |child| find_matches(child, matches) }
      when Psych::Pure::LoadedArray
        value.each { |child| find_matches(child, matches) }
      end

      matches
    end
  end
end
