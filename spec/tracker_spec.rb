require 'spec_helper'

describe Fastdfs::Client::Tracker do 

  it "get storage server" do 
    @tracker = Fastdfs::Client::Tracker.new("192.168.9.16", "22122")
    storage = @tracker.get_storage
    puts "=======#{storage.host}"
    results = storage.upload(File.open("/Users/huxinghai/Documents/shark/app/assets/images/page.png"))
    puts results
    puts storage.delete(results[:path], results[:group_name])
  end
end