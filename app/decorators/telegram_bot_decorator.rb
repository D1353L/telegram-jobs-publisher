# frozen_string_literal: true

class TelegramBotDecorator
  def self.publish_to_channel(**args)
    silent = silent_time?(
      ENV['SILENT_FROM_HOUR']&.to_i,
      ENV['SILENT_TO_HOUR']&.to_i
    )

    Telegram.bot.send_message(
      chat_id: ENV['CHANNEL_ID'],
      disable_web_page_preview: true,
      parse_mode: 'html',
      disable_notification: silent,
      **args
    )
  end

  def self.silent_time?(from, to)
    hours = (0..23).to_a
    if hours.include?(from) && hours.include?(to)
      period = from < to ? hours[from...to] : (hours[from..-1] + hours[0...to])
      return period.include? Time.now.hour
    end
    false
  end
end
