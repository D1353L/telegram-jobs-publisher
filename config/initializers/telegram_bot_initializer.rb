# frozen_string_literal: true

class TelegramBotInitializer
  class << self
    PROGNAME = 'TelegramJobsPublisher'

    def perform(api_key:, webhook_url:, **options)
      set_up_bot_config api_key, options[:whitelist]
      set_webhook webhook_url

      @log_dir = options.fetch(:log_dir, '.')
      @log_chat_id = options[:log_chat_id]
      @chat_log_level = options.fetch(:chat_log_level, 'info')
      connect_loggers
    end

    def set_up_bot_config(api_key, whitelist)
      Telegram.bots_config = {
        default: {
          token: api_key,
          whitelist: whitelist
        }
      }
    end

    private

    def connect_loggers
      logger = Telegram::JobsPublisher::LoggersPool.new(
        loggers: {
          stdout_logger: Logger.new($stdout),
          file_logger: file_logger,
          chat_logger: chat_logger
        },
        progname: PROGNAME
      )
      Telegram.instance_variable_set(:@logger, logger)
      Telegram.class.send(:attr_reader, :logger)
    end

    def set_webhook(webhook_url)
      if Telegram.bot.get_webhook_info.dig('result', 'url') == webhook_url
        return
      end

      Telegram.bot.set_webhook(url: webhook_url)
    end

    def file_logger
      Telegram::JobsPublisher::FileLogger.new(
        "#{@log_dir}/telegram_jobs_publisher.log"
      )
    end

    def chat_logger
      Telegram::JobsPublisher::ChatLogger.new(
        chat_id: @log_chat_id,
        log_level: @chat_log_level,
        message_sender: lambda { |chat_id, message|
          Telegram.bot.send_message(chat_id: chat_id, text: message)
        }
      )
    end
  end
end
