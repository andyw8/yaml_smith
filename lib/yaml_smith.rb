# frozen_string_literal: true

require_relative 'yaml_smith/version'
require 'psych/pure'
require 'tempfile'

module YamlSmith
  class Error < StandardError; end

  # Adds a top-level key to a YAML file.
  class AddKey
    def initialize(path, key, value)
      @path = path
      @key = key
      @value = value
    end

    def self.call(...)
      new(...).call
    end

    def call
      document = load_file(@path)
      value = load(@value)

      ensure_mapping(document)
      ensure_key_absent(document)
      document[@key] = value
      write(Psych::Pure.dump(document))
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

    def ensure_key_absent(document)
      return unless document.key?(@key)

      raise Error, "key already exists: #{@key}"
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
