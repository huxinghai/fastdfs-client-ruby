module ActionDispatch
  module Http

    class UploadedFile
      attr_accessor :original_filename

      attr_accessor :content_type

      attr_accessor :tempfile
      alias :to_io :tempfile

      attr_accessor :headers

      def initialize(hash)
        @tempfile          = hash[:tempfile]
        raise(ArgumentError, ":tempfile is required") unless @tempfile

        @original_filename = hash[:filename]
        if @original_filename
          begin
            @original_filename.encode!(Encoding::UTF_8)
          rescue EncodingError
            @original_filename.force_encoding(Encoding::UTF_8)
          end
        end
        @content_type      = hash[:type]
        @headers           = hash[:head]
      end

      def read(length=nil, buffer=nil)
        @tempfile.read(length, buffer)
      end

      def open
        @tempfile.open
      end

      def close(unlink_now=false)
        @tempfile.close(unlink_now)
      end

      def path
        @tempfile.path
      end

      def rewind
        @tempfile.rewind
      end

      def size
        @tempfile.size
      end

      def eof?
        @tempfile.eof?
      end
    end
  end
end