require 'tempfile'

module Fastdfs
  module Client

    class Storage
      extend Hook

      before(:upload, :delete){ @socket.connection }
      after(:upload, :delete){ @socket.close }

      attr_accessor :host, :port, :group_name, :store_path, :socket, :options

      def initialize(host, port, store_path = nil, options = {})
        @host = host
        @port = port
        @options = options || {}
        @options = store_path if store_path.is_a?(Hash)
        @socket = Socket.new(host, port, @options[:socket])
        @extname_len = ProtoCommon::EXTNAME_LEN
        @size_len = ProtoCommon::SIZE_LEN        
        @store_path = store_path || 0
      end

      def upload(file)  
        _upload(file)
      end

      def delete(path, group_name = nil)
        cmd = CMD::DELETE_FILE
        path_bytes = group_path_bytes(cmd, path, group_name)
        @socket.write(cmd, path_bytes)
        @socket.receive{ true }
      end

      def get_metadata(path, group_name = nil)
        cmd = CMD::GET_METADATA
        path_bytes = group_path_bytes(cmd, path, group_name)
        @socket.write(cmd, path_bytes)
        @socket.receive do |content|
          res = content.split(ProtoCommon::RECORD_SEPERATOR).map do |c| 
            c.split(ProtoCommon::FILE_SEPERATOR) 
          end.flatten
          Utils.symbolize_keys(Hash[*res])
        end
      end

      private
      def group_path_bytes(cmd, path, group_name = nil)
        group_name, path = extract_path!(path, group_name)
        group_bytes = group_name.bytes.fill(0, group_name.length...ProtoCommon::GROUP_NAME_MAX_LEN)
        path_bytes = group_bytes + path.bytes
        return (ProtoCommon.header_bytes(cmd, path_bytes.length) + path_bytes)
      end

      def extract_path!(path, group_name = nil)
        raise "path arguments is empty!" if path.blank?
        if group_name.blank?
          group_name = /^\/?(\w+)/.match(path)[1]
          path = path.gsub(Regexp.new("/?#{group_name}/?"), "")
        end
        raise "group_name arguments is empty!" if group_name.blank?
        return group_name, path
      end

      def _upload(file)
        cmd = CMD::UPLOAD_FILE

        extname = File.extname(file)[1..-1]
        ext_name_bs = extname.bytes.fill(0, extname.length...@extname_len)
        hex_len_bytes = Utils.number_to_Buffer(file.size)
        size_byte = [@store_path].concat(hex_len_bytes).fill(0, (hex_len_bytes.length+1)...@size_len)

        header = ProtoCommon.header_bytes(cmd, (size_byte.length + @extname_len + file.size))
        pkg = header + size_byte + ext_name_bs

        @socket.write(cmd, pkg)
        @socket.write(cmd, IO.read(file))
        @socket.receive do |body|
          group_name_max_len = ProtoCommon::GROUP_NAME_MAX_LEN
          
          {
            group_name: body[0...group_name_max_len].strip, 
            path: body[group_name_max_len..-1]
          }
        end
      end
      
    end

  end
end