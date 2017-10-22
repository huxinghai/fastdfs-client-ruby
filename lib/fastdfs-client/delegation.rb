module Fastdfs
  module Client

    module Delegation
      module ClassMethods
        
        def delegate(*methods, to:)
          methods.each do |m|
            class_eval <<-EVAL, __FILE__, __LINE__ + 1
              def #{m}(*args, &block)
                #{to}.#{m}(*args, &block)
              end
            EVAL
          end
        end
      end
      
      def self.included(receiver)
        receiver.extend ClassMethods
      end
    end

  end
end
