module TestConfig
  STORAGE_IP = "192.168.8.23"
  STORAGE_PORT = "23000"
  STORE_PATH = 0
  GROUP_NAME = "group1"
  FILE_NAME = "M00/04/47/wKgIF1cHcQyAeAF7AAACVHeY6n8267.png"

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