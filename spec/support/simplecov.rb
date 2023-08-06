# frozen_string_literal: true

require "simplecov"
require "simplecov-lcov"
require "simplecov_json_formatter"
require "simplecov/formatter/multi_formatter"

SimpleCov.root File.expand_path("../..", __dir__)
SimpleCov.coverage_dir "coverage"

SimpleCov::Formatter::LcovFormatter.config.report_with_single_file = true

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new([
                                                                 SimpleCov::Formatter::HTMLFormatter,
                                                                 SimpleCov::Formatter::LcovFormatter,
                                                                 SimpleCov::Formatter::JSONFormatter
                                                               ])

SimpleCov.start
