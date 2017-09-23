require 'tempfile'

module Fastdfs
  module Client

    class Storage
      attr_accessor :proxy, :options, :socket, :store_path

      def initialize(host, port, store_path = nil, options = {})
        @options = options || {}
        @options = store_path if store_path.is_a?(Hash)

        @proxy = ClientProxy.new(host, port, @options[:socket])
        @socket = @proxy.socket
        @store_path = store_path || 0
      end

      def upload(_file, options = {})  
        file, ext_name_bytes = convert_file_info(_file)
        size_byte = [@store_path].concat(file.size.to_eight_buffer).full_fill(0, file_size_len)
        # content_len = file_size_len + extname_len + file.size
        byte = size_byte + ext_name_bytes
        method = keep_alive_upload? options
        @proxy.public_send(method, CMD::UPLOAD_FILE, byte , IO.read(file)) do |body|
          group_name_max_len = ProtoCommon::GROUP_NAME_MAX_LEN
          res = {group_name: body[0...group_name_max_len].strip, path: body[group_name_max_len..-1]}
          _set_metadata(res[:path], res[:group_name], options) unless options.blank?
          res
        end
      end

      def keep_alive_upload? options
        alive = options.delete(:alive)
        alive ? :keep_alive : :dispose
      end

      def delete(path, group_name = nil)
        header_bytes = group_path_bytes(path, group_name).flatten
        @proxy.dispose(CMD::DELETE_FILE, header_bytes)
      end

      def get_metadata(path, group_name = nil)
        header_bytes = group_path_bytes(path, group_name).flatten
        @proxy.dispose(CMD::GET_METADATA, header_bytes) do |body|
          res = body.split(ProtoCommon::RECORD_SEPERATOR).map do |c| 
            c.split(ProtoCommon::FILE_SEPERATOR) 
          end.flatten
          Hash[*res].fs_symbolize_keys
        end
      end

      def set_metadata(path, group_name = nil, options = {}, flag = :cover)
        flag, options = options, {} unless options.is_a?(Hash)
        options, group_name = group_name, nil if group_name.is_a?(Hash)
        _set_metadata(path, group_name, options, flag)
      end

      def download(path, group_name = nil)
        path_bytes = group_path_bytes(path, group_name).flatten
        header_bytes = 0.to_eight_buffer.concat(0.to_eight_buffer).concat(path_bytes)
        @proxy.dispose(CMD::DOWNLOAD_FILE, header_bytes) do |body|
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
        return group_name, path
      end

      def _set_metadata(path, group_name = nil, options = {}, flag = :cover)
        flag = convert_meta_flag(flag)
        group_bytes, path_bytes = group_path_bytes(path, group_name)
        meta_bytes = meta_to_bytes(options)

        size_bytes = path_bytes.length.to_eight_buffer.concat(meta_bytes.length.to_eight_buffer).full_fill(0, 16)
        # total = size_bytes.length + flag.length + group_bytes.length + path_bytes.length + meta_bytes.length
        @proxy.dispose(CMD::SET_METADATA, (size_bytes + flag.bytes + group_bytes + path_bytes), meta_bytes.pack("C*"))
      end

      def convert_meta_flag(flag)
        data = {
          cover: ProtoCommon::SET_METADATA_FLAG_OVERWRITE,
          merge: ProtoCommon::SET_METADATA_FLAG_MERGE
        }
        flag ||= :cover 
        data[flag.to_sym]
      end

      def meta_to_bytes(options = {})
        meta_bytes = options.map do |a| 
          a.join(ProtoCommon::FILE_SEPERATOR) 
        end.join(ProtoCommon::RECORD_SEPERATOR).bytes
        meta_bytes << 0 if meta_bytes.length <= 0
        meta_bytes
      end

      def create_tempfile(path, body)
        tmp = Tempfile.new(path.gsub(/\//, "_"))
        tmp.binmode
        tmp.write(body)
        tmp.close
        tmp
      end

      def extname_len; ProtoCommon::EXTNAME_LEN end;
      def file_size_len; ProtoCommon::SIZE_LEN end;

      def convert_file_info(file)
        if file.class.name == "ActionDispatch::Http::UploadedFile"
          return file.tempfile, convert_extname_bytes(file.original_filename)
        else
          return file, convert_extname_bytes(file.path)
        end
      end

      def convert_extname_bytes(file_name)
        File.extname(file_name)[1..extname_len].to_s.bytes.full_fill(0, extname_len)
      end
    end

  end
end