class CommandsController < ApplicationController

  def schedule!(*params)
    every = params.any? ? schedule_params(params)[:every] : '2h'
    return unless every
    ScheduleService.schedule! every
    respond_with :message, text: "Scheduled every #{every}"
  end

  def status!(*)
    respond_with :message, text: ScheduleService.status
  end

  def reset!(*)
    ScheduleService.reset!
    respond_with :message, text: 'Schedule reset successfully'
  end

  def log_level!(*)
    respond_with :message, text: 'Hello!'
  end

  private

  def schedule_params(params)
    return {} unless params.size == 1 && params.first.match(/^\d*\.?\d*(m|h)?$/)

    permitted_params = { every: params.first }
    permitted_params
  end
end
