require 'socket'
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
        @socket = TCPSocket.new(@host, @port) if @socket.nil? || !connected
      end

      def connected
        !@socket.closed?
      end

      def receive
        @content = nil
        recv_header
        @content = @socket.recv(@header.to_pack_long)
      end

      def recv_header
        @header = @socket.recv(@header_len).unpack("C*")
        puts "header: #{@header}, #{@cmd}"
        parseHeader
      end

      private
      def parseHeader
        raise "recv package size #{@header} != #{@header_len}" unless @header.length == @header_len
        raise "recv cmd: #{@header[8]} is not correct, expect cmd: #{CMD::RESP_CODE}" unless @header[8] == CMD::RESP_CODE
        raise "recv erron #{@header[9]}, 0 is correct" unless @header[9] == 0
        {status: true, body_length: 0}
      end

    end
  end
end