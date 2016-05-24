require 'fastdfs-client/storage'

module Fastdfs
  module Client

    class Tracker

      attr_accessor :socket, :cmd, :options

      def initialize(host, port, options = {})
        @options = options
        @socket = Socket.new(host, port, @options[:socket])
        @cmd = CMD::STORE_WITHOUT_GROUP_ONE
      end

      def get_storage
        client = ClientProxy.new(@cmd, @socket, 0)
        res = client.dispose do |body|
          storage_ip = body[ProtoCommon::IPADDR].strip
          storage_port = body[ProtoCommon::PORT].unpack("C*").to_pack_long
          store_path = body[ProtoCommon::TRACKER_BODY_LEN-1].unpack("C*")[0]
        
          Storage.new(storage_ip, storage_port, store_path, @options)
        end
        res[:status] ? res[:result] : res
      end
    end

  end
end