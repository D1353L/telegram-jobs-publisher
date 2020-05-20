# frozen_string_literal: true

require 'httparty'

module APIClient
  class HhRu
    include ::HTTParty
    base_uri 'api.hh.ru'

    REQUEST_PARAMS = {
      order_by: 'publication_time',
      schedule: 'remote',
      period: 1,
      page: 1,
      per_page: 1
    }.freeze

    CURRENCIES = {
      'RUR' => 'руб.',
      'BYN' => 'бел. руб.',
      'UAH' => 'грн.',
      'USD' => '$',
      'EUR' => '€'
    }.freeze

    class << self
      def create_job_ad!
        vacancy_id = vacancies(REQUEST_PARAMS)&.first&.dig('id')
        return nil unless vacancy_id

        @payload = vacancy(vacancy_id)
        return nil unless @payload

        formatter.format_message
      end

      private

      def vacancies(params)
        response = get('/vacancies', query: params)
        return [] if response.code != 200

        response['items']
      end

      def vacancy(id)
        response = get("/vacancies/#{id}")
        return nil if response.code != 200

        response
      end

      def formatter
        JobAdFormatter.new(
          title: @payload['name'],
          company: company,
          experience: @payload.dig('experience', 'name'),
          salary: salary,
          description: description,
          skills: key_skills,
          link: @payload['alternate_url'],
          published_at: @payload['published_at']
        )
      end

      def salary
        if @payload.dig('salary', 'from')
          from = "от #{@payload['salary']['from']}"
        end
        to = " до #{@payload['salary']['to']}" if @payload.dig('salary', 'to')
        currency = @payload.dig('salary', 'currency')

        return 'з/п не указана' unless from || to

        "#{from}#{to} #{CURRENCIES[currency] || currency}".strip
      end

      def company
        employer_name = @payload.dig('employer', 'name')
        city = @payload.dig('address', 'city') || @payload.dig('area', 'name')

        [employer_name, city].compact.join ', '
      end

      def description
        @payload['description']&.gsub(%r{</?[^>]+?>}, '')
      end

      def key_skills
        @payload['key_skills']&.map { |skill| skill['name'] }&.join(', ')
      end
    end
  end
end
