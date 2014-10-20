ENV['RACK_ENV'] = 'test'

$:.unshift(File.join(File.dirname(__FILE__), "..", "lib"))

require 'byebug'
require 'rspec'
require 'content_gateway'

begin
  require 'simplecov'
  SimpleCov.start do
    add_filter '/spec/'
  end
  SimpleCov.coverage_dir 'coverage/rspec'
rescue LoadError
  # ignore simplecov in ruby < 1.9
end

# This file was generated by the `rspec --init` command. Conventionally, all
# specs live under a `spec` directory, which RSpec adds to the `$LOAD_PATH`.
# Require this file using `require "spec_helper"` to ensure that it is only
# loaded once.
#
# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'
end
