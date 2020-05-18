# frozen_string_literal: true

class ScheduleService
  SCHEDULE_NAME = 'jobs_publisher'

  class << self
    def schedule!(every)
      Sidekiq.set_schedule(
        SCHEDULE_NAME,
        {
          class: PublishWorker.to_s,
          args: api_client.to_s,
          every: every
        }
      )
    end

    def reset!
      Sidekiq.remove_schedule(SCHEDULE_NAME)
      Sidekiq::ScheduledSet.new.clear
      Sidekiq::Queue.all.each(&:clear)
      Sidekiq::RetrySet.new.clear
    end

    def status
      schedule = Sidekiq.get_schedule(SCHEDULE_NAME)
      return 'No jobs scheduled' unless schedule

      "Job scheduled every #{schedule['every']}"
    end

    private

    def api_client
      APIClient::HhRu
    end
  end
end
