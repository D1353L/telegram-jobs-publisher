# frozen_string_literal: true

require 'active_record'
require 'erb'
require 'pg'

RACK_ENV = ENV['RACK_ENV']&.to_sym || :development
puts "#{RACK_ENV} mode"

ActiveRecord::Base.logger = Telegram::JobsPublisher::LoggersPool.new(
  loggers: {
    stdout_logger: Logger.new($stdout)
  },
  progname: 'TelegramJobsPublisherDB'
)

if ENV['LOG_DIR']
  ActiveRecord::Base.logger[:file_logger] = Telegram::JobsPublisher::FileLogger.new(
    "#{ENV['LOG_DIR']}/telegram_jobs_publisher.log"
  )
end

ActiveRecord::Base.logger.each { |logger| logger.level = ENV['LOG_LEVEL'] }

DB_CONF = YAML.safe_load(
  ERB.new(IO.read('config/database.yml')).result,
  aliases: true
)

ActiveRecord::Base.schema_format = :sql
ActiveRecord::Base.configurations = DB_CONF
ActiveRecord::Base.establish_connection(DB_CONF.fetch(RACK_ENV.to_s))
