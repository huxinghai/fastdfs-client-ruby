module Fastdfs
  module Client

    module ProtoCommon
      TRACKER_BODY_LEN = 40
      
      IPADDR = 16...31
      PORT = 31...-1
      SIZE_LEN = 9
      HEAD_LEN = 10
      EXTNAME_LEN = 6
      GROUP_NAME_MAX_LEN = 16

      RECV_MAX_LEN = 2 * 1024

      RECORD_SEPERATOR = "\u0001"
      FILE_SEPERATOR = "\u0002"

      SET_METADATA_FLAG_OVERWRITE = "O"
      SET_METADATA_FLAG_MERGE = "M"

      def self.header_bytes(cmd, hex_long, erron=0)
        hex_bytes = Utils.number_to_buffer(hex_long)
        header = hex_bytes.fill(0, hex_bytes.length...HEAD_LEN)
        header[8] = cmd
        header[9] = erron
        header
      end
    end

  end
end