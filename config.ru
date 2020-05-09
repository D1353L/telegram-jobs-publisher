require 'pry'
require 'dotenv/load'
require 'telegram/bot'
require 'require_all'
require_all 'app'

file = File.new("telegram_jobs_publisher.log", 'a+')
file.sync = true
use Rack::CommonLogger, file

Telegram.bots_config = {
  default: {
    token: ENV['API_KEY'],
    whitelist: ENV['WHITELIST']
  }
}

if Telegram.bot.get_webhook_info.dig('result', 'url') != ENV['WEBHOOK_URL']
  Telegram.bot.set_webhook(url: ENV['WEBHOOK_URL'])
end

map "/telegram" do
  run Telegram::Bot::Middleware.new(Telegram.bot, CommandsController)
end
