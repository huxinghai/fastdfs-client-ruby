require 'debugger'
require 'rspec'
require 'rspec/core'
require 'rspec/mocks'
require File.expand_path('../../lib/client', __FILE__)

RSpec.configure do |config|
  config.mock_with :rspec do |c|
    c.syntax = [:should, :expect]
  end
end


@tracker = TrackerClient.new("192.168.9.16", "22122")
storage = @tracker.get_storage
storage.upload(File.open("/Users/huxinghai/Documents/shark/app/assets/images/page.png"))