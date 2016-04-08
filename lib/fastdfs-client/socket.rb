require 'socket'
require 'timeout'
require 'fastdfs-client/cmd'


module Fastdfs
  module Client

    class Socket
      attr_accessor :header, :content, :header_len, :cmd, :socket, :host, :port

      def initialize(host, port)
        @host = host
        @port = port
        connection
        @header_len = 10
        @connection_timeout = 3
        @recv_timeout = 3
      end

      def write(*args)
        @cmd = args.shift
        pkg = args.shift
        pkg = pkg.pack("C*") if pkg.is_a?(Array)
        @socket.write pkg
      end

      def close 
        @socket.close if connected
      end

      def connection
        if @socket.nil? || !connected
          Timeout.timeout(@connection_timeout) do
            @socket = TCPSocket.new(@host, @port)  
          end
        end
      end

      def connected
        !@socket.closed?
      end

      def receive
        @content = nil
        Timeout.timeout(@recv_timeout) do 
          @header = @socket.recv(@header_len).unpack("C*")
        end
        res_header = parseHeader
        if res_header[:body_length] > 0
          Timeout.timeout(@recv_timeout) do 
            @content = @socket.recv(@header.to_pack_long) 
          end
        end
        yield @content if block_given?
      end

      private
      def parseHeader
        raise "recv package size #{@header} != #{@header_len}" unless @header.length == @header_len
        raise "recv cmd: #{@header[8]} is not correct, expect cmd: #{CMD::RESP_CODE}" unless @header[8] == CMD::RESP_CODE
        raise "recv erron #{@header[9]}, 0 is correct" unless @header[9] == 0
        {status: true, body_length: @header[0...8].to_pack_long}
      end

    end
  end
end