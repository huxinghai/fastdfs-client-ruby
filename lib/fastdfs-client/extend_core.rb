
class Array

  def to_pack_long
    self.each_with_index.inject(0){|s, item| s = s | (item[0] << (56 - (item[1] * 8))); s }
  end
end