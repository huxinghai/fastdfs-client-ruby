require 'tempfile'

module Fastdfs
  module Client

    class Storage
      extend Hook

      before(:upload, :delete){ @socket.connection }
      after(:upload, :delete){ @socket.close }

      attr_accessor :host, :port, :group_name, :store_path

      def initialize(host, port)
        @host = host
        @port = port
        @socket = Socket.new(host, port)
        @extname_len = ProtoCommon::EXTNAME_LEN
        @size_len = ProtoCommon::SIZE_LEN
      end

      # File.open("/Users/huxinghai/Downloads/1279304.jpeg")
      # ext_name 6 byte
      # size_bytes 16 第一位是store_path_index
      # master_filename_bytes ISO8859-1
      # slave body size_byte + prefix_max_size(16) + ext_name(6) + master_filename_bytes + file_size
      # standard body size_byte + ext_name + file_size
      # cmd 11 
      # header = cmd + body_len  ... 11 ...29
      # write file bytes
      def upload(file)  
        _upload(file)
      end

      def delete(path, group_name = nil)
        cmd = CMD::DELETE_FILE
        raise "path arguments is empty!" if path.blank?
        if group_name.blank?
          group_name = /^\/?(\w+)/.match(path)[1]
          path = path.gsub("/#{group_name}")
        end
        raise "group_name arguments is empty!" if group_name.blank?
        group_bytes = group_name.bytes.fill(0, group_name.length...16)
        path_length = (group_bytes.length + path.bytes.length)

        @socket.write(cmd, (ProtoCommon.header_bytes(cmd, path_length) + group_bytes + path.bytes))
        @socket.recv_header
      end

      private 
      def _upload(file)
        cmd = CMD::UPLOAD_FILE

        extname = File.extname(file)[1..-1]
        ext_name_bs = extname.to_s.bytes.fill(0, extname.length...@extname_len)
        hex_len_bytes = Utils.number2Buffer(file.size)
        size_byte = [store_path].concat(hex_len_bytes).fill(0, (hex_len_bytes.length+1)...@size_len)

        header = ProtoCommon.header_bytes(cmd, (size_byte.length + @extname_len + file.size))
        pkg = header + size_byte + ext_name_bs
        
        @socket.write(cmd, pkg)
        @socket.write(cmd, IO.read(file))
        @socket.receive
        
        {group_name: Utils.pack_trim(@socket.content[0..15]), path: @socket.content[16..-1]}
      end
      
    end

  end
end