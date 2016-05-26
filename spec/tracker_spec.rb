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
    expect(tracker.socket).to receive(:connection)
    expect(tracker.socket).to receive(:close)
    tracker.get_storage
  end

  it "should have access to the storage class" do 
    expect(tracker.get_storage.class).to eq(FC::Storage)
  end

  it "verify the server address and port" do 
    expect(tracker.get_storage.socket.host).to eq(TestConfig::STORAGE_IP)
    #[0, 0, 0, 0, 0, 89, 216, 0]
    expect(tracker.get_storage.socket.port.to_s).to eq(TestConfig::STORAGE_PORT)
    expect(tracker.get_storage.store_path).to eq(TestConfig::STORE_PATH)
  end

  it "get to the server failed" do 
    result = FC::ProtoCommon.header_bytes(FC::CMD::RESP_CODE, 0, 22)
    MockTCPSocket.any_instance.stub("recv").and_return(result.pack("C*"))
    expect(tracker.get_storage).to be_a_kind_of(Hash)
    expect(tracker.get_storage[:status]).to be_falsey
  end

  it "run server flow" do 
    # 1.times.map do
    #   tracker.get_storage
    # end

    # storage = tracker.get_storage
    # puts "#{storage.host}, #{storage.port}"
    # results = storage.upload(File.open("/Users/huxinghai/Documents/shark/app/assets/images/page.png"))
    # puts results
    # puts storage.delete(results[:path], results[:group_name])
  end
end