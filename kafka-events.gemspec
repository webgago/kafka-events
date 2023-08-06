# frozen_string_literal: true

require_relative "lib/kafka/events/version"

Gem::Specification.new do |spec|
  spec.name          = "kafka-events"
  spec.version       = Kafka::Events::VERSION
  spec.authors       = ["Anton Sozontov"]
  spec.email         = ["a.sozontov@gmail.com"]
  spec.license       = "MIT"

  spec.summary       = "Create and validate events for Event Driven Architecture (EDA)."
  spec.description   = spec.summary
  spec.homepage      = "https://github.com/webgago/kafka-events"

  spec.metadata["allowed_push_host"] = "https://rubygems.com"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/webgago/kafka-events"
  spec.metadata["changelog_uri"] = "https://github.com/webgago/kafka-events/blob/main/CHANGELOG.md"
  spec.metadata["bug_tracker_uri"] = "https://github.com/webgago/kafka-events/issues"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.7"

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "activesupport", ">= 5.0"
  spec.add_dependency "dry-struct", "~> 1.6"
  spec.add_dependency "dry-validation", "~> 1.10"
  spec.add_development_dependency "pry-byebug", "~> 3.10"
  spec.add_development_dependency "rspec", "~> 3.12"
  spec.add_development_dependency "rspec_junit_formatter", "~> 0.6"
  spec.add_development_dependency "rubocop", "~> 1.45"
  spec.add_development_dependency "rubocop-rspec", "~> 2.22"
  spec.add_development_dependency "simplecov", "~> 0.22"
  spec.add_development_dependency "simplecov-lcov", "~> 0.8"

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
  spec.metadata["rubygems_mfa_required"] = "true"
end
