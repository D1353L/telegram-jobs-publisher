# frozen_string_literal: true

require 'redis'
require 'resque/tasks'
require 'resque/scheduler/tasks'

namespace :resque do
  task :setup do
    require 'resque'

    ENV['QUEUE'] = '*'

    loggers = loggers(
      progname: 'TelegramJobsPublisherWorker',
      log_file_name: 'resque_worker.log'
    )
    loggers.each { |logger| logger.level = :info }

    TelegramBotInitializer.set_up_bot_config

    Resque.logger = loggers
  end

  task setup_schedule: :setup do
    require 'resque-scheduler'
    Resque::Scheduler.dynamic = true

    loggers = loggers(
      progname: 'TelegramJobsPublisherScheduler',
      log_file_name: 'resque_scheduler.log'
    )
    loggers.each { |logger| logger.level = :info }

    Resque::Scheduler.logger = loggers
  end

  task scheduler: :setup_schedule
end

def loggers(progname: nil, log_file_name: nil)
  Telegram::JobsPublisher::LoggersPool.new(
    loggers: {
      stdout_logger: Logger.new($stdout),
      file_logger: Telegram::JobsPublisher::FileLogger.new(
        "#{ENV['LOG_DIR']}/#{log_file_name}"
      )
    },
    progname: progname
  )
end
