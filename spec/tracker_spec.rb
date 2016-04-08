require 'spec_helper'

describe Fastdfs::Client::Tracker do 

  let(:host){ "192.168.9.16" }
  let(:port){ "22122" }
  let(:tracker){ Fastdfs::Client::Tracker.new(host, port) }


  it "get storage server" do 
    storage = tracker.get_storage
    results = storage.upload(File.open("/Users/huxinghai/Documents/shark/app/assets/images/page.png"))
    puts storage.delete(results[:path], results[:group_name])
  end
end