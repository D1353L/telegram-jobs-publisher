# frozen_string_literal: true

class ApplicationController < Telegram::Bot::UpdatesController
  before_action :log_incomming_message, :authorize

  private

  def authorize
    return if !whitelist || whitelist.include?(from[:id].to_s)

    Telegram.logger.debug 'Access denied'
    raise Telegram::Bot::Forbidden
  end

  def log_incomming_message
    Telegram.logger.debug "Incoming message: text=#{payload[:text]}. "\
                          "From: id=#{from[:id]} "\
                          "first_name=#{from[:first_name]} "\
                          "last_name=#{from[:last_name]} "\
                          "username=#{from[:username]}"
  end

  def whitelist
    @whitelist ||= Telegram.bots_config.dig(:default, :whitelist)
      &.split(',')&.flatten&.map(&:to_s)
  end
end
