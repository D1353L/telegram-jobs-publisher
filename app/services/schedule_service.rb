# frozen_string_literal: true

class ScheduleService
  SCHEDULE_NAME = 'publish_job'

  class << self
    def schedule!(every)
      Resque.set_schedule(
        SCHEDULE_NAME,
        {
          class: PublishJob.to_s,
          args: api_client.to_s,
          every: every,
          persist: true
        }
      )
    end

    def reset!
      Resque.remove_schedule(SCHEDULE_NAME)
    end

    def status
      return 'No jobs scheduled' if Resque.schedule.empty?

      "Job scheduled every #{Resque.schedule.dig(SCHEDULE_NAME, 'every')}"
    end

    private

    def api_client
      APIClient::HhRu
    end
  end
end
