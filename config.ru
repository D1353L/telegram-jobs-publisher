# frozen_string_literal: true

require 'pry'
require 'logger'
require 'dotenv/load'
require 'telegram/bot'
require 'sidekiq/web'
require 'sidekiq-scheduler/web'
require 'require_all'
require_all 'app'
require_all 'config'
require_all 'lib'

TelegramBotInitializer.perform(
  api_key: ENV['API_KEY'],
  webhook_url: ENV['WEBHOOK_URL'],
  whitelist: ENV['WHITELIST'],
  log_dir: ENV['LOG_DIR'],
  log_chat_id: ENV['LOG_CHAT_ID'],
  chat_log_level: ENV['INITIAL_LOG_LEVEL']
)

Telegram.logger.info 'Server is started'
Telegram.logger.info ScheduleService.status

app = Rack::Builder.new do
  use LoggingMiddleware, Telegram.logger
  map '/telegram' do
    run Telegram::Bot::Middleware.new(Telegram.bot, CommandsController)
  end

  map '/sidekiq' do
    run Sidekiq::Web
  end
end

CustomThinHandler.run app
