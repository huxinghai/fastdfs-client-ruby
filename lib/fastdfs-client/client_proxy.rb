require 'monitor'

module Fastdfs
  module Client

    class ClientProxy
      include MonitorMixin

      attr_accessor :host, :port, :socket, :alive

      def initialize(host, port, options = {})
        super()
        options ||= {}
        @host, @port = host, port
        @alive = options.delete(:alive) || false
        
        @socket = Socket.new(host, port, options)
      end

      def dispose(cmd, header = [], content = [], &block)
        synchronize do
          @socket.connection do
            contents = Array(content)
            body_len = contents.map{|c| c.bytes.size }.inject(header.length){|sum, x| sum + x }
            full_header = ProtoCommon.header_bytes(cmd, body_len).concat(header)
            @socket.write(cmd, full_header)
            contents.each do |c|
              @socket.write(cmd, c)
            end
            @socket.receive &block
          end            
        end
      ensure
        @socket.close unless @alive   
      end
      
    end
  end
end