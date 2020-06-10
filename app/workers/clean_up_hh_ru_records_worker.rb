# frozen_string_literal: true

class CleanUpHhRuRecordsWorker
  include Sidekiq::Worker

  # Removes all records but leaves last n
  def perform(records_to_leave_number)
    records_to_leave_number = records_to_leave_number.to_i
    query = HhRuRecord.order('created_at')
    count = query.count

    if count > records_to_leave_number
      query.limit(count - records_to_leave_number).destroy_all
      logger.info 'CleanUpHhRuRecordsWorker: Database was successfully '\
                  "cleaned except #{records_to_leave_number} last records"
    end
  end
end
