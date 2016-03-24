class PackHeader
  attr_accessor :pack

  def initialize(pack)
    @pack = pack
  end

  def resolve
    @pack.inject(0){|s, i| s = (s | i); s }
  end
end