module Utils

  def self.number_to_Buffer(num)
    8.times.map{|i| (num >> (56 - 8 * i)) & 255}
  end

  def self.pack_trim(str)
    str.gsub(/\x00/, '')
  end

  def self.array_merge(arr1, arr2)
    raise "argument must be array" unless arr1.is_a?(Array) || arr2.is_a?(Array)
    arr2.each_with_index.map{|v, i| arr1[i] = v }
    arr1
  end

end