require 'debugger'
require 'rspec'
require 'rspec/core'
require 'rspec/mocks'
require File.expand_path('../../lib/client', __FILE__)
require File.expand_path('../test_config', __FILE__)
require File.expand_path('../mock_tcp_socket', __FILE__)


RSpec.configure do |config|
  config.mock_with :rspec do |c|
    c.syntax = [:should, :expect]
  end
end
