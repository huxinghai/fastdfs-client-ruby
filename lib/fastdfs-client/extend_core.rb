class Array
  def to_pack_long
    self.each_with_index.inject(0){|s, item| s = s | (item[0] << (56 - (item[1] * 8))); s }
  end
  
  def full_fill(val, len)
    self.fill(val, self.length...len)
  end
end

class NilClass
  def blank?
    true
  end
end

class String
  def blank?
    self.strip.empty?
  end
end

class Object
  def blank?
    respond_to?(:empty?) ? empty? : !self
  end
end

class Integer
  def to_eight_buffer
    8.times.map{|i| (self >> (56 - 8 * i)) & 255}
  end
end

class Hash

  def fs_symbolize_keys
    defined?(super) ? super : self.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
  end

end