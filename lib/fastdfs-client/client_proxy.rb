require 'monitor'

module Fastdfs
  module Client

    class ClientProxy
      include MonitorMixin

      attr_accessor :host, :port, :socket

      def initialize(host, port, options = {})
        super()
        options ||= {}
        @host = host
        @port = port
        
        @socket = Socket.new(host, port, options[:socket])
      end

      def dispose(cmd, content_len, header = [], content = [], &block)
        synchronize do
          @socket.connection do 
            full_header = ProtoCommon.header_bytes(cmd, content_len) + header
            @socket.write(cmd, full_header)
            Array(content).each do |c|
              @socket.write(cmd, c)
            end
            @socket.receive &block
          end
        end
      ensure
        @socket.close
      end
    end

  end
end