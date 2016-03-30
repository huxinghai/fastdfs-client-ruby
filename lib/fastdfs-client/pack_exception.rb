module Fastdfs
  module Client

    class PackException 
      attr_accessor :packs, :max_len

      def initialize(packs)
        @packs = packs
        @max_len = 10
      end

      def dispose
        # 0,0,0,0,0,0,0,40,100,0
        raise "recv package size #{@packs} != #{@max_len}" if @packs.length != @max_len
        raise "recv cmd: #{@packs[8]} is not correct, expect cmd: #{100}" if @packs[8] != 100
        return {erron: @packs[9], body_len: 0} if @packs[9] != 0
        pkg = PackHeader.new(@packs).resolve
        raise "recv body length: #{pkg} is not correct, expect length: 40" if pkg != 40
      end
    end

  end
end