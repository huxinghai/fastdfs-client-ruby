module TestConfig
  STORAGE_IP = "192.168.1.168"
  STORAGE_PORT = "23000"
  STORE_PATH = 0
  GROUP_NAME = "group1"
  FILE_PATH = "M00/04/47/wKgIF1cHcQyAeAF7AAACVHeY6n8267.png"
  SOCKET_DEFAULT_OPTION =  {connection_timeout: 3, recv_timeout: 20}

  METADATA = {
    width: "800",
    height: "600",
    bgcolor: 'red',
    author: "kaka"
  }

  FILE = Tempfile.new("test.jpg")
  FILE.write("testtest")
  FILE.close

end