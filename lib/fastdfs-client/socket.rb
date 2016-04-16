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
        @recv_timeout = @options[:recv_timeout] || 20
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

      def receive(&block)
        timeout_recv do 
          @header = @socket.recv(@header_len).unpack("C*")
        end
        res_header = parseHeader
        if res_header[:status]
          recv_body if is_recv?
          res = yield(@content) if block_given?
          res_header[:result] = res unless res.nil?
        end
        res_header
      end

      private
      def parseHeader
        err_msg = ""
        err_msg = "recv package size #{@header} is not equal #{@header_len}, cmd: #{@cmd}" unless @header.length == @header_len
        err_msg = "recv cmd: #{@header[8]} is not correct, expect cmd: #{CMD::RESP_CODE}, cmd: #{@cmd}" unless @header[8] == CMD::RESP_CODE
        err_msg = "recv erron #{@header[9]}, 0 is correct cmd: #{@cmd}" unless @header[9] == 0
        {status: err_msg.blank?, err_msg: err_msg}
      end

      def timeout_recv
        Timeout.timeout(@recv_timeout) do 
          yield if block_given?
        end
      end

      def is_recv?
        recv_body_len > 0
      end

      def recv_body_len
        @header[0...8].to_pack_long
      end

      def recv_body
        @content = ""
        max_len, body_len = ProtoCommon::RECV_MAX_LEN, recv_body_len

        while body_len > 0
          timeout_recv do 
            len = [body_len, max_len].min
            @content << @socket.recv(len) 
            body_len -= len
          end
        end
        @content = nil if @content.blank?
      end

    end
  end
end