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

    def resolve_container(document)
      container = document
      segments[0..-2].each { |segment| container = navigate(container, segment) }
      [container, segments.last]
    end

    def navigate(container, segment)
      if integer?(segment)
        raise Error, "expected an array at '#{segment}'" unless container.instance_of?(Psych::Pure::LoadedArray)

        index = Integer(segment)
        raise Error, "segment does not exist: #{segment}" if index >= container.length

        container[index]
      else
        raise Error, "expected a mapping at '#{segment}'" unless container.instance_of?(Psych::Pure::LoadedHash)
        raise Error, "segment does not exist: #{segment}" unless container.key?(segment)

        container[segment]
      end
    end

    def integer?(segment)
      segment.match?(/\A\d+\z/)
    end

    def segments
      @segments ||= parse_segments(@key)
    end

    def parse_segments(key)
      return [key] unless key.include?('.') || key.include?('[')

      key.scan(/[^.\s]+/).each_with_object([]) do |token, result|
        segments = token.split('[')
        result << segments[0] unless segments[0].empty?

        segments[1..].each do |part|
          result << part.delete_suffix(']')
        end
      end
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
