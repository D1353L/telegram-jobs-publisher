# frozen_string_literal: true

require 'active_record'
require 'dotenv/load'
require 'telegram/bot'
require 'sidekiq-scheduler'
require 'require_all'
require_all 'app'
require_all 'lib'
require_all 'config/initializers'

TelegramBotInitializer.set_up_bot_config(ENV['API_KEY'], nil)

Sidekiq.logger = Telegram::JobsPublisher::LoggersPool.new(
  loggers: {
    stdout_logger: Logger.new($stdout)
  },
  progname: 'TelegramJobsPublisherWorkers'
)

if ENV['LOG_DIR']
  Sidekiq.logger[:file_logger] = Telegram::JobsPublisher::FileLogger.new(
    "#{ENV['LOG_DIR']}/sidekiq.log"
  )
end

Sidekiq.logger.each { |logger| logger.level = ENV['LOG_LEVEL'] }

if ENV['DEFAULT_SCHEDULE_VALUE']
  ScheduleService.schedule!(ENV['DEFAULT_SCHEDULE_VALUE'])
end
