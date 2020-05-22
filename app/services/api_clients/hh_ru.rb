# frozen_string_literal: true

require 'httparty'

module APIClient
  class HhRu
    include ::HTTParty
    base_uri 'api.hh.ru'

    CURRENCIES = {
      'RUR' => 'руб.',
      'BYN' => 'бел. руб.',
      'UAH' => 'грн.',
      'USD' => '$',
      'EUR' => '€'
    }.freeze

    class << self
      def create_job_ad!
        query_params = JSON.parse(ENV['HH_RU_VACANCIES_PARAMS'])
        vacancy_id = vacancies(query_params)&.first&.dig('id')

        return { error: 'Unable to fetch vacancy id' } unless vacancy_id

        if HhRuRecord.last&.id&.to_s == vacancy_id
          return { info: 'The last vacancy is already published' }
        end

        save_id_to_db vacancy_id

        @payload = vacancy(vacancy_id)
        return nil unless @payload

        { message: formatter.format_message }
      end

      private

      def save_id_to_db(record_id)
        if HhRuRecord.last
          HhRuRecord.last.update(id: record_id)
        else
          HhRuRecord.new(id: record_id).save!
        end
      end

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
