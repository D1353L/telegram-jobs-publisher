class ApplicationController < Telegram::Bot::UpdatesController
  before_action :authenticate_request

  def authenticate_request
    whitelist = Telegram.bots_config.dig(:default, :whitelist)&.split(',')
    raise Telegram::Bot::Error unless whitelist && whitelist.include?(from['id'].to_s)
  end
end
