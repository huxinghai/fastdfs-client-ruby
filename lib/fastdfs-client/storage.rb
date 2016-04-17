require 'tempfile'

module Fastdfs
  module Client

    class Storage
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

      def upload(file, options = {})  
        ext_name_bs = File.extname(file)[1..-1].bytes.full_fill(0, @extname_len)
        size_byte = ([@store_path] + Utils.number_to_buffer(file.size)).full_fill(0, @size_len)
        content_len = (@size_len + @extname_len + file.size)

        client = ClientProxy.new(CMD::UPLOAD_FILE, @socket, content_len, size_byte + ext_name_bs)
        client.push_content{ IO.read(file) }
        client.dispose do |body|
          group_name_max_len = ProtoCommon::GROUP_NAME_MAX_LEN
          
          res = {group_name: body[0...group_name_max_len].strip, path: body[group_name_max_len..-1]}
          _set_metadata(res[:path], res[:group_name], options) unless options.blank?
          res
        end
      end

      def delete(path, group_name = nil)
        path_bytes = group_path_bytes(path, group_name).flatten
        client = ClientProxy.new(CMD::DELETE_FILE, @socket, path_bytes.length, path_bytes)
        client.dispose
      end

      def get_metadata(path, group_name = nil)
        path_bytes = group_path_bytes(path, group_name).flatten
        client = ClientProxy.new(CMD::GET_METADATA, @socket, path_bytes.length, path_bytes)
        client.dispose do |body|
          res = body.split(ProtoCommon::RECORD_SEPERATOR).map do |c| 
            c.split(ProtoCommon::FILE_SEPERATOR) 
          end.flatten
          Utils.symbolize_keys(Hash[*res])
        end
      end

      def set_metadata(path, group_name = nil, options = {}, flag = :cover)
        unless options.is_a?(Hash)
          flag = options
          options = {}
        end

        if group_name.is_a?(Hash)
          options = group_name
          group_name = nil
        end
        _set_metadata(path, group_name, options, flag)
      end

      def download(path, group_name = nil)
        path_bytes = group_path_bytes(path, group_name).flatten
        download_bytes = Utils.number_to_buffer(0) + Utils.number_to_buffer(0)
        data = download_bytes + path_bytes
        client = ClientProxy.new(CMD::DOWNLOAD_FILE, @socket, data.length, data)
        client.dispose do |body|
          create_tempfile(path, body) if body
        end
      end

      private
      def group_path_bytes(path, group_name = nil)
        group_name, path = extract_path!(path, group_name)
        group_bytes = group_name.bytes.full_fill(0, ProtoCommon::GROUP_NAME_MAX_LEN)
        [group_bytes, path.bytes]
      end      

      def header_path_bytes(cmd, path, group_name = nil)
        path_bytes = group_path_bytes(path, group_name).flatten
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

      def _set_metadata(path, group_name = nil, options = {}, flag = :cover)
        flag = convert_meta_flag(flag)
        group_bytes, path_bytes = group_path_bytes(path, group_name)
        meta_bytes = meta_to_bytes(options)

        size_bytes = Utils.number_to_buffer(path_bytes.length) + Utils.number_to_buffer(meta_bytes.length)
        size_bytes = (size_bytes).full_fill(0, 16)
        total = size_bytes.length + flag.length + group_bytes.length + path_bytes.length + meta_bytes.length

        client = ClientProxy.new(CMD::SET_METADATA, @socket, total, (size_bytes + flag.bytes + group_bytes + path_bytes))
        client.push_content{ meta_bytes }
        client.dispose
      end

      def convert_meta_flag(flag)
        data = {
          cover: ProtoCommon::SET_METADATA_FLAG_OVERWRITE,
          merge: ProtoCommon::SET_METADATA_FLAG_MERGE
        }
        flag = :cover if flag.blank?
        data[flag.to_sym]
      end

      def meta_to_bytes(options = {})
        meta_bytes = options.map do |a| 
          a.join(ProtoCommon::FILE_SEPERATOR) 
        end.join(ProtoCommon::RECORD_SEPERATOR).bytes
        meta_bytes << 0 if meta_bytes.blank?
        meta_bytes
      end

      def create_tempfile(path, body)
        tmp = Tempfile.new(path.gsub(/\//, "_"))
        tmp.binmode
        tmp.write(body)
        tmp.close
        tmp
      end
      
    end

  end
end