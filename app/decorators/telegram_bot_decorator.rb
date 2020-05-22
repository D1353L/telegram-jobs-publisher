# frozen_string_literal: true

class TelegramBotDecorator
  def self.publish_to_channel
    # period = Chronic.parse("#{ENV['SILENT_FROM_HOUR']} to #{ENV['SILENT_TO_HOUR']}")

    # if period.size == 2
    #   silent = (period.first..period.last).include?(Time.now.hour)
    # end

    Telegram.bot.send_message(
      chat_id: ENV['CHANNEL_ID'],
      disable_web_page_preview: true,
      parse_mode: 'html',
      # disable_notification: silent,
      **args
    )
  end
end
