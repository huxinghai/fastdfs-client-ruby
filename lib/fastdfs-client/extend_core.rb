
class Array
  def to_pack_long
    self.each_with_index.inject(0){|s, item| s = s | (item[0] << (56 - (item[1] * 8))); s }
  end
  
  def full_fill(val, len)
    self.fill(val, self.length...len)
  end
end

class Object

  def blank?
    self.nil? || self.empty?
  end
end