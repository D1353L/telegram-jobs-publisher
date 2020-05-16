# frozen_string_literal: true

module Telegram
  module JobsPublisher
    class LoggersPool
      def initialize(loggers: {}, progname: nil)
        @loggers = loggers
        @progname = progname

        @loggers.each_value { |logger| logger.progname ||= @progname }
      end

      %i[info debug error].each do |method_name|
        define_method(method_name) do |*args, &block|
          @loggers.each_value { |logger| logger.send(method_name, *args, &block) }
        end
      end

      def [](key)
        @loggers[key]
      end

      def []=(key, value)
        value.progname ||= @progname
        @loggers[key] = value
      end

      def each
        @loggers.each_value { |logger| yield logger }
      end
    end
  end
end
