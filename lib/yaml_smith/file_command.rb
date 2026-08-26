# frozen_string_literal: true

module YamlSmith
  # Provides shared YAML file editing behavior for commands.
  class FileCommand
    def initialize(path, key, value = nil)
      @path = path
      @key = key
      @value = value
    end

    def self.call(...)
      new(...).call
    end

    private

    def load_file(path)
      load(File.read(path, encoding: 'UTF-8'))
    rescue SystemCallError => e
      raise Error, e.message
    end

    def load(source)
      Psych::Pure.load(source, comments: true)
    rescue Psych::Exception => e
      raise Error, "invalid YAML: #{e.message}"
    end

    def ensure_mapping(document)
      return if document.instance_of?(Psych::Pure::LoadedHash)

      raise Error, 'YAML document must contain a top-level mapping'
    end

    def write(contents)
      mode = File.stat(@path).mode & 0o7777

      Tempfile.create(['.yaml-smith-', '.tmp'], File.dirname(@path)) do |file|
        file.chmod(mode)
        file.write(contents)
        file.flush
        file.fsync
        File.rename(file.path, @path)
      end
    end
  end
end
