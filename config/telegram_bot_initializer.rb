# frozen_string_literal: true

class TelegramBotInitializer
  class << self
    PROGNAME = 'TelegramJobsPublisher'

    def perform
      set_up_bot_config
      connect_loggers
      set_webhook
    end

    def set_up_bot_config
      Telegram.bots_config = {
        default: {
          token: ENV['API_KEY'],
          whitelist: ENV['WHITELIST']
        }
      }
    end

    def connect_loggers
      logger = Telegram::JobsPublisher::LoggersPool.new(
        loggers: {
          stdout_logger: Logger.new($stdout),
          file_logger: file_logger,
          chat_logger: chat_logger
        },
        progname: PROGNAME
      )
      Telegram.instance_variable_set('@logger', logger)
      Telegram.class.send(:attr_reader, 'logger')
    end

    private

    def set_webhook
      if Telegram.bot.get_webhook_info.dig('result', 'url') == ENV['WEBHOOK_URL']
        return
      end

      Telegram.bot.set_webhook(url: ENV['WEBHOOK_URL'])
    end

    def file_logger
      Telegram::JobsPublisher::FileLogger.new(
        "#{ENV['LOG_DIR']}/telegram_jobs_publisher.log"
      )
    end

    def chat_logger
      Telegram::JobsPublisher::ChatLogger.new(
        chat_id: ENV['LOG_CHAT_ID'],
        log_level: ENV['INITIAL_LOG_LEVEL'],
        message_sender: lambda { |chat_id, message|
          Telegram.bot.send_message(chat_id: chat_id, text: message)
        }
      )
    end
  end
end
