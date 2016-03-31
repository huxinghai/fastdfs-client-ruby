require 'socket'
require 'fastdfs-client/cmd'


module Fastdfs
  module Client

    class Socket < TCPSocket
      attr_accessor :header, :content, :header_len, :cmd

      def initialize(*args)
        super
        @header_len = 10
      end

      def write(*args)
        @cmd = args.shift
        super *args
      end

      def receive
        @header = recv(@header_len).unpack("C*")
        valid_header_exception!
        @content = recv(@header.to_pack_long)
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