require 'socket'
require 'timeout'
require 'fastdfs-client/cmd'


module Fastdfs
  module Client

    class Socket
      attr_accessor :header, :content, :header_len, :cmd, :socket, :host, :port

      def initialize(host, port, options = {})
        @host, @port = host, port
        @header_len = ProtoCommon::HEAD_LEN
        @options = options || {}
        @connection_timeout = @options[:connection_timeout] || 3
        @recv_timeout = @options[:recv_timeout] || 3
        connection
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
        raise "recv package size #{@header} != #{@header_len}, cmd: #{@cmd}" unless @header.length == @header_len
        raise "recv cmd: #{@header[8]} is not correct, expect cmd: #{CMD::RESP_CODE}, cmd: #{@cmd}" unless @header[8] == CMD::RESP_CODE
        raise "recv erron #{@header[9]} 0 is correct, cmd: #{@cmd}" unless @header[9] == 0
        {status: true, body_length: @header[0...8].to_pack_long}
      end

    end
  end
end