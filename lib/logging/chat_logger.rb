# frozen_string_literal: true

module Telegram
  module JobsPublisher
    class ChatLogger < AppLogger
      LOG_LEVELS = {
        info: 0,
        error: 1,
        debug: 2
      }.freeze

      def initialize(chat_id:, log_level: :info, message_sender: nil)
        @chat_id = chat_id
        @chat_log_level = LOG_LEVELS[log_level&.to_sym || :info]
        @message_sender = message_sender
        @formatter = Formatter.new
        super(nil)
      end

      def info(message)
        send_message(message) if @chat_log_level >= LOG_LEVELS[:info]
      end

      def debug(message)
        return if @chat_log_level < LOG_LEVELS[:debug]

        send_message(format_msg(DEBUG, message))
      end

      def error(message)
        return if @chat_log_level < LOG_LEVELS[:error]

        send_message(format_msg(ERROR, message))
      end

      def set_level(level)
        level = level.to_sym
        level_value = LOG_LEVELS[level]

        if level_value
          @chat_log_level = level_value
          return level
        end

        false
      end

      def human_log_level
        LOG_LEVELS.key(@chat_log_level)
      end

      private

      def send_message(message)
        unless @message_sender
          raise NoMethodError,
                'Define message_sender as a Proc or lambda with params [:chat_id, :message]'
        end

        @message_sender.call(@chat_id, message)
      end

      def format_msg(severity, msg)
        format_message(format_severity(severity), Time.now, progname, msg)
      end
    end
  end
end
