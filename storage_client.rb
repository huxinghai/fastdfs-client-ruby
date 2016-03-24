class StorageClient
  attr_accessor :host, :port, :group_name, :store_path

  def initialize(host, port)
    @host = host
    @port = port
  end
end