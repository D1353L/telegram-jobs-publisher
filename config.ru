# frozen_string_literal: true

require 'active_record'
require 'logger'
require 'dotenv/load'
require 'telegram/bot'
require 'sidekiq/web'
require 'sidekiq-scheduler/web'
require 'require_all'
require_all 'lib'
require_all 'app'
require_all 'config'

TelegramBotInitializer.perform(
  api_key: ENV['API_KEY'],
  webhook_url: "#{ENV['WEBHOOK_URL']}/telegram",
  whitelist: ENV['WHITELIST'],
  log_dir: ENV['LOG_DIR'],
  log_chat_id: ENV['LOG_CHAT_ID'],
  chat_log_level: ENV['CHAT_LOG_LEVEL']
)

Telegram.logger.info 'Server is started'
Telegram.logger.info ScheduleService.status

Sidekiq::Web.use(Rack::Auth::Basic) do |user, password|
  [user, password] == [ENV['SIDEKIQ_USERNAME'], ENV['SIDEKIQ_PASSWORD']]
end

app = Rack::Builder.new do
  use LoggingMiddleware, Telegram.logger

  map '/telegram' do
    run Telegram::Bot::Middleware.new(Telegram.bot, CommandsController)
  end

  map '/sidekiq' do
    run Sidekiq::Web
  end
end

CustomThinHandler.run(app, {Port: ENV['PORT']})
