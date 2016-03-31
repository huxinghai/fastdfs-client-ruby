module Utils

  def long_convert_bytes(num)
    8.times.map{|i| (num >> (56 - 8 * i)) & 255}
  end

  def pack_trim(str)
    str.gsub(/\x00/, '')
  end

end