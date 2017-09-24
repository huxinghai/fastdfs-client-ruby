require 'fastdfs-client/storage'

module Fastdfs
  module Client

    class Tracker
      
      attr_accessor :options, :socket

      def initialize(options = {})
        @options = default_options.merge(options)
        @options[:trackers] = [@options[:trackers]] if @options[:trackers].is_a?(Hash)
        
        @proxies = @options[:trackers].map do |tracker| 
          opt = tracker.fs_symbolize_keys
          ClientProxy.new(opt[:host], opt[:port], extract_proxy_options.merge(alive: true)) 
        end

      end

      def get_storage(alive = false)
        res = proxy.dispose(CMD::STORE_WITHOUT_GROUP_ONE) do |body|
          storage_ip = body[ProtoCommon::IPADDR].strip
          storage_port = body[ProtoCommon::PORT].unpack("C*").to_pack_long
          store_path = body[ProtoCommon::TRACKER_BODY_LEN-1].unpack("C*")[0]
        
          Storage.new(storage_ip, storage_port, store_path, extract_proxy_options.merge(alive: alive))
        end
        raise res[:err_msg] unless res[:status]
        res[:result]
      end

      def pipelined
        storage = get_storage(true)
        yield storage
        storage.proxy.close
      end

      def proxy
        @proxy_index ||= -1
        @proxy_index += 1
        @proxy_index = 0 if @proxy_index >= @proxies.length
        @proxies[@proxy_index]
      end

      private 

      def default_options
        {
          trackers: [
            {host: "127.0.0.1", port: "22122"}
          ],
          connection_timeout: 3,
          recv_timeout: 20
        }
      end

      def extract_proxy_options
        keys = [:connection_timeout, :recv_timeout]
        @options.select{|key| keys.include?(key) }
      end
    end

  end
end