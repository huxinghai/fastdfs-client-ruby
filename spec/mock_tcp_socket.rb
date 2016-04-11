
class TCPSocket
  include Fastdfs::Client

  attr_accessor :host, :port, :cmd, :recv_offset, :connect_state

  def initialize(host, port)
    @host = host
    @port = port
    @recv_offset = 0
    @connect_state = true
    @cmd = nil
  end

  def write(*args)
    pkg = args[0].unpack("C*")
    @cmd ||= pkg[8] 
  end

  def recv(len)
    recv_data = recv_config[@cmd.to_s] || {}
    data = recv_data.key?(:recv_bytes) ? recv_data[:recv_bytes].call(len) : nil
    @recv_offset = len
    data
  end

  def close
    @recv_offset = 0
    @connect_state = false
    @cmd = nil
  end

  def closed?
    @connect_state
  end

  private 

  def recv_config
    {
      "101" => {
        recv_bytes: lambda do |len|
          header = ProtoCommon.header_bytes(CMD::RESP_CODE, 0)
          header[7] = ProtoCommon::TRACKER_BODY_LEN

          group_name = Utils.array_merge([].fill(0, 0...16), TestConfig::GROUP_NAME.bytes)
          ip = Utils.array_merge([].fill(0, 0...15), TestConfig::STORAGE_IP.bytes)
          port = Utils.number_to_Buffer(TestConfig::STORAGE_PORT.to_i)
          store_path = Array(TestConfig::STORE_PATH)

          (header+group_name+ip+port+store_path)[@recv_offset...@recv_offset+len].pack("C*")
        end
      },
      "11" => {
        recv_bytes: lambda do |len|
          header = ProtoCommon.header_bytes(CMD::RESP_CODE, 0)
          group_name = Utils.array_merge([].fill(0, 0...16), TestConfig::GROUP_NAME.bytes)
          file_name = TestConfig::FILE_NAME.bytes
          res = (group_name + file_name)
          header[7] = (header + res).length
          res = (header + res)
          
          res[@recv_offset...@recv_offset+len].pack("C*")
        end
      },
      "12" => {
        recv_bytes: lambda do |len|
          ProtoCommon.header_bytes(CMD::RESP_CODE, 0).pack("C*")
        end
      }
    }
  end
end