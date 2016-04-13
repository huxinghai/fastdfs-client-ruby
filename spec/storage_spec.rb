require 'spec_helper'

describe Fastdfs::Client::Storage do 

  let(:host){ "192.168.9.16" }
  let(:port){ "22122" }

  let(:tracker){ FC::Tracker.new(host, port) }
  let(:storage){ tracker.get_storage }

  # it "initialize the server" do 
  #   expect(FC::Socket).to receive(:new).with(host, port, nil) 
  #   FC::Storage.new(host, port) 
  # end

  # it "should have access to the storage connection" do
  #   expect(storage.socket).to receive(:connection)
  #   expect(storage.socket).to receive(:close)
  #   storage.upload(TestConfig::FILE)
  # end

  # it "should the result attributes group_name and path" do 
  #   res = storage.upload(TestConfig::FILE)
  #   expect(res).to include(:group_name)
  #   expect(res).to include(:path)
  # end

  # it "can delete file by group and path" do 
  #   res = storage.upload(TestConfig::FILE)
  #   storage.delete(res[:path], res[:group_name])
  # end

  # it "can delete file raise exception" do 
  #   res = storage.upload(TestConfig::FILE)
  #   result = FC::ProtoCommon.header_bytes(FC::CMD::RESP_CODE, 0, 22)
  #   TCPSocket.any_instance.stub("recv").and_return(result.pack("C*"))
  #   expect{ storage.delete("fdsaf", res[:group_name]) }.to raise_error(RuntimeError)
  # end

  it "should metadata results" do 
    res = storage.get_metadata("#{TestConfig::GROUP_NAME}/#{TestConfig::FILE_NAME}")
    expect(res).to eq(TestConfig::METADATA)
  end
end