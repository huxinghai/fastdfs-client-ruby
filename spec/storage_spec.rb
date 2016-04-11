require 'spec_helper'

describe Fastdfs::Client::Storage do 

  let(:host){ "192.168.9.16" }
  let(:port){ "22122" }

  let(:tracker){ FC::Tracker.new(host, port) }
  let(:storage){ tracker.get_storage }

  it "initialize the server" do 
    expect(FC::Socket).to receive(:new).with(host, port) 
    FC::Storage.new(host, port) 
  end

  it "should have access to the storage connection" do
    expect(storage.socket).to receive(:connection)
    expect(storage.socket).to receive(:close)
    storage.upload(TestConfig::FILE)
  end



end