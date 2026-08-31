# Agent Guide

## Commands

- Install dependencies with `bundle install`.
- Run all tests with `bundle exec rake test`.
- Run one test file with `bundle exec ruby -Ilib:test test/test_add_key.rb` (replace the filename as needed).
- The CI/default task is `bundle exec rake`, which runs tests followed by RuboCop.

## Structure

- `exe/yaml-smith` is only the executable wrapper; CLI dispatch and error handling belong in `lib/yaml_smith/cli.rb`.
- Each command has its own class and file: `AddKey`, `SetKey`, and `DeleteKey`.
- Shared file loading, validation, and atomic writing live in `YamlSmith::FileCommand`.
- `AddKey` and `SetKey` accept a nested path in their `key` argument using dot
  notation (e.g. `services.0.name`) or bracket notation (e.g. `services[0].name`).
  Numeric segments index into arrays. `FileCommand#resolve_container` navigates
  intermediate segments of the path, which must already exist; the final key may
  be missing (for `set`, it is then added). `DeleteKey` searches matching keys
  recursively and does not take a path.

## YAML Behavior

- Use `Psych::Pure`, not standard `Psych`; it is required to preserve comments where possible.
- Load existing files and values with `comments: true`.
- Values passed on the command line are YAML and should retain their YAML types.
- File edits are written through a same-directory temporary file and rename; preserve this atomic-write behavior.
- In tests, use squiggly heredocs (`<<~YAML`) for multiline YAML fixtures and expected YAML output so the structure remains readable.
