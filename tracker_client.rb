require 'socket'

class TrackerClient
  attr_accessor :socket, :host, :port

  def initialize(host, port)
    @recv_length = 40
    @host = host
    @port = port
    @socket = TCPSocket.new(host, port)
  end

  def get_storage
    items = 8.times.map{|i| 0 } << 101 << 0
    @socket.write(items)
    @socket.recv(@recv_length)
  end


end