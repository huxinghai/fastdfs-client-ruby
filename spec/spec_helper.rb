if RUBY_VERSION.start_with?('2')
  require 'byebug'
else
  require 'debugger'
end
require 'rspec'
require 'rspec/core'
require 'rspec/mocks'
require 'upload'
require File.expand_path('../../lib/fastdfs-client', __FILE__)
require File.expand_path('../test_config', __FILE__)
require File.expand_path('../mock_tcp_socket', __FILE__)

FC = Fastdfs::Client

RSpec.configure do |config|
  config.before(:each) do 
    TCPSocket.stub(:new) do |h, p|
      MockTCPSocket.new(h, p)
    end
  end 
  config.mock_with :rspec do |c|
    c.syntax = [:should, :expect]
  end
end
  
