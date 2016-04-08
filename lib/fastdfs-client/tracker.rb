require 'fastdfs-client/storage'

module Fastdfs
  module Client

    class Tracker
      extend Hook

      before(:upload, :delete){ @socket.connection }
      after(:upload, :delete){ @socket.close }

      attr_accessor :socket, :cmd

      def initialize(host, port)
        @socket = Socket.new(host, port)
        @cmd = CMD::STORE_WITHOUT_GROUP_ONE
      end

      def get_storage
        header = ProtoCommon.header_bytes(@cmd, 0)
        @socket.write(@cmd, header)
        @socket.receive do |body|
          storage_ip = Utils.pack_trim(body[ProtoCommon::IPADDR])
          storage_port = body[ProtoCommon::PORT].unpack("C*").to_pack_long
          store_path = body[ProtoCommon::BODY_LEN-1].unpack("C*")[0]

          Storage.new(storage_ip, storage_port, store_path)
        end


      end
    end

  end
end