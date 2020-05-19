# frozen_string_literal: true

class CommandsController < ApplicationController
  SCHEDULE_PARAM_PATTERN = /^\d*\.?\d*(m|h)$/.freeze
  ACCEPTED_LOG_LEVEL_VALUES = %w[info error debug].freeze

  def publish!(*)
    message = APIClient::HhRu.create_job_ad!
    TelegramBotDecorator.publish_to_channel(text: message, parse_mode: 'html')
    respond_with(:message, text: 'New job published') if message
  end

  def schedule!(*params)
    every = params.any? ? schedule_params(params)[:every] : ENV['DEFAULT_SCHEDULE_VALUE']
    return unless every

    ScheduleService.schedule! every
    respond_with_status_info
  end

  def status!(*)
    respond_with_status_info
  end

  def reset!(*)
    ScheduleService.reset!
    respond_with_status_info
  end

  def log_level!(*params)
    chat_logger = Telegram.logger[:chat_logger]
    return unless chat_logger

    respond_with(:message, text: chat_logger.human_log_level) if params.empty?

    new_log_level = log_level_params(params)[:log_level]
    return unless new_log_level

    chat_logger.set_level new_log_level
    respond_with :message, text: "Log level is set to #{new_log_level}"
  end

  private

  def respond_with_status_info
    respond_with :message, text: ScheduleService.status
  end

  def schedule_params(params)
    unless params.size == 1 && params.first.match(SCHEDULE_PARAM_PATTERN)
      return {}
    end

    { every: params.first }
  end

  def log_level_params(params)
    unless params.size == 1 && ACCEPTED_LOG_LEVEL_VALUES.include?(params.first)
      return {}
    end

    { log_level: params.first }
  end
end
