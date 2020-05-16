# frozen_string_literal: true

require 'pry'
require 'logger'
require 'dotenv/load'
require 'telegram/bot'
require 'require_all'
require_all 'app'
require_all 'config'
require_all 'lib'

TelegramBotInitializer.perform

Telegram.logger.info 'Server is started'
Telegram.logger.info ScheduleService.status

app = Rack::Builder.new do
  use LoggingMiddleware, Telegram.logger
  map '/telegram' do
    run Telegram::Bot::Middleware.new(Telegram.bot, CommandsController)
  end
end

CustomThinHandler.run app
