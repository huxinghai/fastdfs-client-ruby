require 'socket'
require 'tempfile'

module Fastdfs
  module Client

    class Storage
      attr_accessor :host, :port, :group_name, :store_path

      def initialize(host, port)
        @host = host
        @port = port
        @socket = TCPSocket.new(host, port)
        @extname_len = 6
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
        case file

        when Tempfile

        when File
          extname = File.extname(file)[1..-1]
          ext_name_bs = extname.bytes.fill(0, extname.length..(@extname_len-1))
          hex_len_bytes = log2buff(file.size)
          size_byte = [store_path].concat(hex_len_bytes).fill(0, (hex_len_bytes.length+1)..8)
          body_len = size_byte.length + @extname_len + file.size
          hex_bytes = log2buff(body_len)
          header = hex_bytes.fill(0, hex_bytes.length..9)
          header[8] = 11 #cmd
          header[9] = 0   #erroron
          # debugger
          pkg = header + size_byte + ext_name_bs
          @socket.write(pkg.pack("c*"))
          @socket.write(file.read.unpack("c*").pack("c*"))
          header = @socket.recv(10)
          recv_len = PackHeader.new(header.bytes).resolve
          body = @socket.recv(recv_len)
          puts body[0..15]
          puts body[16..-1]
        when String

        else
          raise "data type exception #{file}"
        end
      ensure
        @socket.close
      end

      def log2buff(num)
        8.times.map{|i| (num >> (56 - 8 * i)) & 255}
      end
    end
    
  end
end