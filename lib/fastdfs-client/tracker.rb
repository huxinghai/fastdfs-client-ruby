require 'socket'

module Fastdfs
  module Client

    class Tracker
      attr_accessor :socket, :host, :port

      def initialize(host, port)
        @host = host
        @port = port
        @socket = TCPSocket.new(host, port)
      end

      def get_storage
        items = 8.times.map{|i| 0 } << 101 << 0
        @socket.write(items.pack("c*"))
        #103,114,111,117,112,49,0,0,0,0,0,0,0,0,0,0,49,57,50,46,49,54,56,46,56,46,50,51,0,0,0,0,0,0,0,0,0,89,216,0
        PackException.new(@socket.recv(10))
        packs = @socket.recv(ProtoCommon::BODY_LEN)
        ip_addr = packs[ProtoCommon::IPADDR].gsub(/\x00/, '')
        @pack_header = PackHeader.new(packs[ProtoCommon::PORT].unpack("C*"))
        store_path = packs[ProtoCommon::BODY_LEN-1].unpack("C*")[0]
        storage = StorageClient.new(ip_addr, @pack_header.resolve)
        storage.store_path = store_path
        return storage
      ensure
        @socket.close
      end
    end
    
  end
end