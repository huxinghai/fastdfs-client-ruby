require 'spec_helper'

describe Fastdfs::Client::Tracker do 

  let(:host){ "192.168.9.16" }
  let(:port){ "22122" }

  let(:tracker){ FC::Tracker.new(host, port) }

  it "initialize the server" do 
    expect(FC::Socket).to receive(:new).with(host, port, nil) 
    FC::Tracker.new(host, port) 
  end

  it "should have access to the storage connection" do
    expect(tracker.socket).to receive(:connection).and_return({})
    expect(tracker.socket).to receive(:close)
    tracker.get_storage
  end

  it "should have access to the storage class" do 
    expect(tracker.get_storage.class).to eq(FC::Storage)
  end

  it "verify the server address and port" do 
    expect(tracker.get_storage.socket.host).to eq(TestConfig::STORAGE_IP)

    expect(tracker.get_storage.socket.port.to_s).to eq(TestConfig::STORAGE_PORT)
    expect(tracker.get_storage.store_path).to eq(TestConfig::STORE_PATH)
  end

  it "get to the server failed" do 
    result = FC::ProtoCommon.header_bytes(FC::CMD::RESP_CODE, 0, 22)
    MockTCPSocket.any_instance.stub("recv").and_return(result.pack("C*"))
    expect(tracker.get_storage).to be_a_kind_of(Hash)
    expect(tracker.get_storage[:status]).to be_falsey
  end

  it "multi thread upload" do 
    items = 6.times.map do
      Thread.new do 
        storage = tracker.get_storage
        res = storage.upload(File.open(File.expand_path("../page.png", __FILE__)))
        expect(res[:status]).to be_truthy
        results = res[:result]
        results = storage.delete(results[:path], results[:group_name])
        expect(res[:status]).to be_truthy
      end
    end

    items.map{|item|  item.join }
  end

end