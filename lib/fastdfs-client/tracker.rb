require 'fastdfs-client/storage'

module Fastdfs
  module Client

    class Tracker
      
      include Delegation

      attr_accessor :options

      delegate :upload, :delete, :get_metadata, :set_metadata, :download, to: :get_storage

      def initialize(options = {})
        @options = default_options_merge(options)
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
      ensure
        storage.proxy.close
      end

      private 
      def default_options_merge(options = {})
        opts = default_options.merge(options)
        tracker = {host: opts.delete(:host), port: opts.delete(:port)}
        if !tracker[:host].nil?
          opts[:trackers] = [tracker]
        elsif opts[:trackers].is_a?(Hash)
          opts[:trackers] = [opts[:trackers]]
        end
        opts
      end

      def default_options
        {
          host: nil,
          port: nil,
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

      def proxy
        @proxy_index ||= -1
        @proxy_index += 1
        @proxy_index = 0 if @proxy_index >= @proxies.length
        @proxies[@proxy_index]
      end
    end

  end
end