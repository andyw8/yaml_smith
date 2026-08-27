# YamlSmith

A command-line tool for manipulating YAML files while preserving comments,
powered by [Psych::Pure](https://github.com/kddnewton/psych-pure).

## Installation

Install the gem and add it to your application's Gemfile:

```bash
bundle add yaml_smith
```

If Bundler is not being used, install the gem directly:

```bash
gem install yaml_smith
```

## Usage

Add a top-level key to an existing YAML file:

```bash
yaml-smith add config.yml timeout 30
```

The value is parsed as YAML, so values such as `true`, `null`, arrays, and
objects retain their YAML types. Existing keys are not overwritten.

Set or replace a top-level key:

```bash
yaml-smith set config.yml timeout 60
```

Delete matching keys recursively:

```bash
yaml-smith delete config.yml timeout
```

Delete searches mappings nested inside arrays and other mappings. For example,
this removes the `WEB_CONCURRENCY` entry from a nested `envVars` list:

```bash
yaml-smith delete render.yaml WEB_CONCURRENCY
```

Use `--top-level-only` to restrict deletion to the document's top-level keys:

```bash
yaml-smith delete config.yml timeout --top-level-only
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then,
run `bundle exec rake test` to run the tests. You can also run `bin/console` for
an interactive prompt.

To install this gem locally, run `bundle exec rake install`. To release a new
version, update `version.rb`, then run `bundle exec rake release`.

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/andyw8/yaml_smith.

## License

The gem is available as open source under the terms of the [MIT
License](https://opensource.org/licenses/MIT).
