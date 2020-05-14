# frozen_string_literal: true

class ApplicationInitializer
  class << self
    def perform
      Telegram.bots_config = {
        default: {
          token: ENV['API_KEY'],
          whitelist: ENV['WHITELIST']
        }
      }

      connect_loggers
      set_webhook

      Telegram.logger.info 'Server is started'
    end

    private

    def connect_loggers
      logger = Telegram::JobsPublisher::LoggersPool.new(
        stdout_logger: stdout_logger,
        file_logger: file_logger,
        chat_logger: chat_logger
      )
      Telegram.instance_variable_set('@logger', logger)
      Telegram.class.send(:attr_reader, 'logger')
    end

    def set_webhook
      if Telegram.bot.get_webhook_info.dig('result', 'url') == ENV['WEBHOOK_URL']
        return
      end

      Telegram.bot.set_webhook(url: ENV['WEBHOOK_URL'])
    end

    def stdout_logger
      Telegram::JobsPublisher::AppLogger.new($stdout)
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
