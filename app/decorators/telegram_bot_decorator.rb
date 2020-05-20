# frozen_string_literal: true

class TelegramBotDecorator
  def self.publish_to_channel(**args)
    silent_at_night = [0..8].include? Time.now.hour

    Telegram.bot.send_message(
      chat_id: ENV['CHANNEL_ID'],
      disable_web_page_preview: true,
      parse_mode: 'html',
      disable_notification: silent_at_night,
      **args
    )
  end
end
