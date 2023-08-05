# frozen_string_literal: true

require "simplecov"

SimpleCov.root File.expand_path("../..", __dir__)
SimpleCov.coverage_dir "tmp/coverage"
SimpleCov.start
