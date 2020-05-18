# frozen_string_literal: true

require 'pry'
require 'dotenv/load'
require 'telegram/bot'
require 'sidekiq-scheduler'
require 'require_all'
require_all 'app'
require_all 'lib'
require_all 'config'

Sidekiq::Scheduler.dynamic = true

TelegramBotInitializer.set_up_bot_config(ENV['API_KEY'], nil)

Sidekiq.logger = Telegram::JobsPublisher::LoggersPool.new(
  loggers: {
    stdout_logger: Logger.new($stdout),
    file_logger: Telegram::JobsPublisher::FileLogger.new(
      "#{ENV['LOG_DIR']}/sidekiq.log"
    )
  },
  progname: 'TelegramJobsPublisherWorker'
)

Sidekiq.logger.each { |logger| logger.level = :info }
