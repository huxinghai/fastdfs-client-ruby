module Fastdfs
  module Client

    module CMD
      STORE_WITHOUT_GROUP_ONE = 101
      UPLOAD_FILE = 11
      RESP_CODE = 100
      DELETE_FILE = 12
      GET_METADATA = 15
      SET_METADATA = 13
      DOWNLOAD_FILE = 14

      MAPPING_NAME = {
        101 => "GET STORAGE",
        11 => "UPLOAD FILE",
        101 => "RESP CODE",
        12 => "DELETE FILE",
        15 => "GET METADATA",
        13 => "SET METADATA",
        14 => "DOWNLOAD FILE"
      }
    end

  end
end