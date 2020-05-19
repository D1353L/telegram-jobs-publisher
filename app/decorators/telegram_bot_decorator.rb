# frozen_string_literal: true

class TelegramBotDecorator
  def self.publish_to_channel(**args)
    Telegram.bot.send_message(chat_id: ENV['CHANNEL_ID'], **args)
  end
end
