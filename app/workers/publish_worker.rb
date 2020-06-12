# frozen_string_literal: true

class PublishWorker
  include Sidekiq::Worker

  def perform(api_client_class_name)
    api_client = Object.const_get api_client_class_name
    response = api_client.create_job_ad!

    logger.warn(response[:error]) if response[:error]
    logger.info(response[:info]) if response[:info]
    return unless response[:message]

    TelegramBotDecorator.publish_to_channel(text: response[:message])
    
    logger.info('New vacancy published to channel')
  end
end
