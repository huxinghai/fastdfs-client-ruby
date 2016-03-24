class PackHeader
  attr_accessor :pack

  def initialize(pack)
    @pack = pack
  end

  def resolve
    @pack.each_with_index.inject(0){|s, item| s = s | (item[0] << (56 - (item[1] * 8))); s }
  end
end