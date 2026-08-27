# frozen_string_literal: true

module YamlSmith
  # Deletes matching keys from a YAML file.
  class DeleteKey < FileCommand
    def call(top_level_only: false)
      document = load_file(@path)

      ensure_mapping(document)
      deleted = top_level_only ? !document.delete(@key).nil? : delete_key(document)
      raise Error, "key does not exist: #{@key}" unless deleted

      write(Psych::Pure.dump(document))
    end

    private

    def delete_key(value)
      return delete_from_array(value) if value.instance_of?(Psych::Pure::LoadedArray)
      return false unless value.instance_of?(Psych::Pure::LoadedHash)

      deleted = value.key?(@key)
      value.delete(@key)
      value.each_value { |child| deleted = delete_key(child) || deleted }
      deleted
    end

    def delete_from_array(value)
      deleted = value.delete_if { |child| child.instance_of?(Psych::Pure::LoadedHash) && child.key?(@key) }.any?
      value.any? { |child| delete_key(child) } || deleted
    end
  end
end
