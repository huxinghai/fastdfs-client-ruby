require 'spec_helper'

describe Fastdfs::Client::Storage do 

  let(:host){ "192.168.9.16" }
  let(:port){ "22122" }

  let(:tracker){ FC::Tracker.new(host, port) }
  let(:storage){ tracker.get_storage }
  let(:tempfile) do 
    file = Tempfile.new("1.txt")
    file.write("testtest")
    file.close
    file
  end

  # it "initialize the server" do 
  #   expect(FC::Socket).to receive(:new).with(host, port, nil) 
  #   FC::Storage.new(host, port) 
  # end

  # it "should have access to the storage connection" do
  #   expect(storage.socket).to receive(:connection)
  #   expect(storage.socket).to receive(:close)
  #   storage.upload(TestConfig::FILE)
  # end

  # it "should have access to the storage connection for 2 items" do
  #   expect(storage.socket).to receive(:connection).at_most(2).times
  #   expect(storage.socket).to receive(:close).at_most(2).times
  #   storage.upload(TestConfig::FILE, {author: "kaka", width: "800"})
  # end

  it "tempfile upload " do 
    res = storage.upload(tempfile)
    expect(res[:status]).to be_truthy
    expect(File.extname(res[:result][:path])).to eq(".txt")
  end

  it "ActionDispatch::Http::UploadedFile upload" do 
    file = ActionDispatch::Http::UploadedFile.new(tempfile: tempfile, filename: "test.txt")
    res = storage.upload(file)
    puts "res: #{res}"
  end

  # describe "upload file test " do 

  #   before(:each) do 
  #     @res_body = storage.upload(TestConfig::FILE)
  #   end

  #   it "should the result attributes group_name and path" do 
  #     expect(@res_body[:status]).to be_truthy
  #     expect(@res_body[:result]).to include(:group_name)
  #     expect(@res_body[:result]).to include(:path)
  #   end

  #   it "can delete file by group and path" do 
  #     res = @res_body[:result]
  #     storage.delete(res[:path], res[:group_name])
  #   end

  #   it "can delete file raise exception" do 
  #     res = @res_body[:result]
  #     result = FC::ProtoCommon.header_bytes(FC::CMD::RESP_CODE, 0, 22)
  #     MockTCPSocket.any_instance.stub("recv").and_return(result.pack("C*"))
  #     expect( storage.delete("fdsaf", res[:group_name])[:status] ).to be_falsey
  #   end

  #   it "can get metadata results" do 
  #     res = @res_body[:result]
  #     storage.set_metadata(res[:path], res[:group_name], TestConfig::METADATA)
  #     res = storage.get_metadata("#{res[:group_name]}/#{res[:path]}")
  #     expect(res[:result]).to eq(TestConfig::METADATA)
  #   end

  #   it "can set metadata" do 
  #     expect(storage.set_metadata(TestConfig::FILE_NAME, TestConfig::GROUP_NAME, TestConfig::METADATA)).to be_truthy
  #   end

  #   it "download the file to the local" do 
  #     res = storage.download(TestConfig::FILE_NAME, TestConfig::GROUP_NAME)
  #     expect(res[:status]).to be_truthy
  #     expect(res[:result]).to be_an_instance_of(Tempfile)
  #     expect(IO.read(res[:result])).to eq(IO.read(TestConfig::FILE))
  #   end
  # end
end