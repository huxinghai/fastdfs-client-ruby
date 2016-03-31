require 'fastdfs-client/socket'
require 'fastdfs-client/storage'
require 'fastdfs-client/cmd'
require 'fastdfs-client/proto_common'
require 'fastdfs-client/utils'

module Fastdfs
  module Client

    class Tracker
      include Utils

      attr_accessor :socket, :host, :port, :cmd

      def initialize(host, port)
        @host = host
        @port = port
        @socket = Socket.new(host, port)
        @cmd = CMD::STORE_WITHOUT_GROUP_ONE
      end

      def get_storage
        header = ([].fill(0, 0..7) << @cmd << 0).pack("C*")
        @socket.write(@cmd, header)
        @socket.receive

        storage_ip = pack_trim(@socket.content[ProtoCommon::IPADDR])
        storage_port = @socket.content[ProtoCommon::PORT].unpack("C*").to_pack_long
        store_path = @socket.content[ProtoCommon::BODY_LEN-1].unpack("C*")[0]

        storage = Storage.new(storage_ip, storage_port)
        storage.store_path = store_path
        return storage
      ensure
        @socket.close
      end
    end

  end
end