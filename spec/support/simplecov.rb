# frozen_string_literal: true

require "simplecov"
require "simplecov-lcov"

SimpleCov.root File.expand_path("../..", __dir__)
SimpleCov.coverage_dir "coverage"

if ENV["CI"]
  SimpleCov::Formatter::LcovFormatter.config.report_with_single_file = true
  SimpleCov.formatter = SimpleCov::Formatter::LcovFormatter
end

SimpleCov.start do
  add_filter "/spec/"
end
