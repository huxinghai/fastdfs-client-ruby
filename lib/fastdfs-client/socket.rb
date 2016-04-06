require 'socket'
require 'fastdfs-client/cmd'


module Fastdfs
  module Client

    class Socket
      attr_accessor :header, :content, :header_len, :cmd, :socket, :host, :port

      def initialize(host, port)
        @host = host
        @port = port
        reconnect
        @header_len = 10
      end

      def write(*args)
        @cmd = args.shift
        @socket.write *args
      end

      def close 
        @socket.close if connected
      end

      def reconnect
        @socket = TCPSocket.new(@host, @port) if @socket.nil? || !connected
      end

      def connected
        !@socket.closed?
      end

      def receive(is_body = true)
        @content = nil
        @header = @socket.recv(@header_len).unpack("C*")
        valid_header_exception!
        @content = @socket.recv(@header.to_pack_long) if is_body
      end

      private
      def valid_header_exception!
        raise "recv package size #{@header} != #{@header_len}" unless @header.length == @header_len
        raise "recv cmd: #{@header[8]} is not correct, expect cmd: #{CMD::RESP_CODE}" unless @header[8] == CMD::RESP_CODE
        raise "recv erron #{@header[9]}, 0 is correct" unless @header[9] == 0
      end

    end
  end
end