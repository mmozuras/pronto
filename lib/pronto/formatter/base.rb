module Pronto
  module Formatter
    class Base
      def self.name
        Formatter::FORMATTERS.invert[self]
      end

      def config
        @config ||= Config.instance
      end
    end
  end
end
