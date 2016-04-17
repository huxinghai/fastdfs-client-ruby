module Fastdfs
  module Client

    class ClientProxy
      attr_accessor :data, :header, :content, :socket

      def initialize(cmd, socket, content_len, header = [])
        @cmd = cmd
        @socket = socket.connection
        @header = ProtoCommon.header_bytes(cmd, content_len) + header
        @content = []
      end

      def push_content
        raise "argument not block!" unless block_given?
        @content << yield
      end

      def dispose(&block)
        @socket.write(@cmd, @header)
        @content.each do |c|
          @socket.write(@cmd, c)
        end
        @socket.receive &block
      ensure
        @socket.close
      end
    end

  end
end