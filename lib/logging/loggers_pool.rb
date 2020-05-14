# frozen_string_literal: true

module Telegram
  module JobsPublisher
    class LoggersPool
      def initialize(loggers = {})
        @loggers = loggers
      end

      %i[info debug error].each do |method_name|
        define_method(method_name) do |msg|
          @loggers.each_value { |logger| logger.send(method_name, msg) }
        end
      end

      def [](key)
        @loggers[key]
      end

      def []=(key, value)
        @loggers[key] = value
      end
    end
  end
end
