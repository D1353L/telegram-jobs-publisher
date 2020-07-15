# frozen_string_literal: true

module Strategies
  class OneTimeOnePost
    CLIENTS = {
      APIClient::HhRu => HhRuRecord,
      APIClient::DouUa => DouUaRecord
    }.freeze

    def create_job_ad!
      sorted_api_clients.first.create_job_ad!
    end

    private

    def sorted_api_clients
      clients = CLIENTS.dup
      clients.delete(APIClient::DouUa) unless ENV['ENABLE_DOU_UA']&.downcase == 'true'

      clients.sort_by { |_k, v| v.last&.created_at }.map(&:first).reverse
    end
  end
end
