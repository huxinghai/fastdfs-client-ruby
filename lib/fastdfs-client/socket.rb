require 'socket'


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
        @header = recv(@header_len)
        valid_header_exception!
        @content = recv(@header.to_pack_long)
      end

      private
      def valid_header_exception!
        raise "recv package size #{@header} != #{@header_len}" unless @header.length == @header_len
        raise "recv cmd: #{@header[8]} is not correct, expect cmd: #{@cmd}" unless @header[8] == @cmd
        return {erron: @header[9], body_len: 0} unless @header[9] == 0
        raise "recv body length: #{@header.to_pack_long} is not correct, expect length: 40" unless @header.to_pack_long == 40
      end

    end
  end
end