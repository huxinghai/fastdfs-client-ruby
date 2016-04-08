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
        @socket.receive

        storage_ip = Utils.pack_trim(@socket.content[ProtoCommon::IPADDR])
        storage_port = @socket.content[ProtoCommon::PORT].unpack("C*").to_pack_long
        store_path = @socket.content[ProtoCommon::BODY_LEN-1].unpack("C*")[0]

        storage = Storage.new(storage_ip, storage_port)
        storage.store_path = store_path
        return storage
      end
    end

  end
end