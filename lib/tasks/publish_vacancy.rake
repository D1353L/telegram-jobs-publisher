desc "Publishes vacancy to channel"
task :publish_vacancy do
  require 'dotenv/load'
  require 'telegram/bot'
  require_all 'config/initializers'
  require_all 'app/decorators'
  require_all 'app/formatters'
  require_all 'app/models'
  require_all 'app/services/api_clients'

  TelegramBotInitializer.set_up_bot_config(ENV['API_KEY'], nil)
  logger = Telegram::JobsPublisher::LoggersPool.new(
    loggers: {
      stdout_logger: Logger.new($stdout)
    },
    progname: 'TelegramJobsPublisherRakeTask'
  )

  response = APIClient::HhRu.create_job_ad!

  logger.warn(response[:error]) if response[:error]
  logger.info(response[:info]) if response[:info]
  next unless response[:message]

  TelegramBotDecorator.publish_to_channel(text: response[:message])

  logger.info('New vacancy published to channel')
end
