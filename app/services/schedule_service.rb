# frozen_string_literal: true

class ScheduleService
  class << self
    def schedule!(every)
      # name = 'send_message_job'
      # config = {}
      # config[:class] = 'SendMessageJob'
      # config[:args] = formatter
      # config[:every] = every
      # config[:persist] = true
      # Resque.set_schedule(name, config)
    end

    def reset!
      # Resque.remove_schedule('send_message_job')
    end

    def status
      'status'
    end

    private

    def formatter; end
  end
end
