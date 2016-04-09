
class TCPSocketa
  include Fastdfs::Client

  attr_accessor :host, :port, :cmd, :recv_offset, :connect_state

  def initialize(host, port)
    @host = host
    @port = port
    @recv_offset = 0
    @connect_state = true
  end

  def write(*args)
    pkg = args[0].unpack("C*")
    @cmd = pkg[8]
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
          ip = Utils.array_merge([].fill(0, 0...16), TestConfig::STORAGE_IP.bytes)
          port = Utils.array_merge([].fill(0, 0...8), TestConfig::STORAGE_PORT.bytes)
          debugger
          
          (header+group_name+ip+port)[@recv_offset...@recv_offset+len].pack("C*")
        end
      }
    }
  end
end