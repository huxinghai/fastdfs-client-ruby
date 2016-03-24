require 'debugger'
require File.expand_path("../pack_header", __FILE__)
require File.expand_path("../proto_common", __FILE__)
require File.expand_path("../storage_client", __FILE__)
require File.expand_path("../tracker_client", __FILE__)


@tracker = TrackerClient.new("192.168.9.16", "22122")
storage = @tracker.get_storage
puts storage.host, storage.port