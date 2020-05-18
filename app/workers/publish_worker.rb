# frozen_string_literal: true

class PublishWorker
  include Sidekiq::Worker

  def perform(api_client_class_name)
    api_client = Object.const_get api_client_class_name
    message = api_client.create_job_ad!
    Telegram.bot.send_message(chat_id: ENV['CHANNEL_ID'], text: message)
  end
end
