# frozen_string_literal: true

require 'httparty'

module APIClient
  class HhRu
    include ::HTTParty
    base_uri 'api.hh.ru'

    CURRENCIES = {
      'RUR' => 'руб.',
      'BYN' => 'бел. руб.',
      'BYR' => 'бел. руб.',
      'UAH' => 'грн.',
      'USD' => '$',
      'EUR' => '€'
    }.freeze

    class << self
      def create_job_ad!
        query_params = JSON.parse(ENV['HH_RU_VACANCIES_PARAMS'])
        vacancy_id = vacancies(query_params)&.first&.dig('id')

        return { error: 'Unable to fetch vacancy id' } unless vacancy_id

        @payload = vacancy(vacancy_id)
        unless @payload
          return { error: "Unable to fetch vacancy with id=#{vacancy_id}" }
        end

        found_record = HhRuRecord.find_by(
          'LOWER(title)= ? AND LOWER(company_name) = ?',
          @payload['name'].downcase, employer_name.downcase
        )

        return { info: 'The vacancy is already published' } if found_record

        if query_params['specialization'] == 1 && !it_vacancy?
          return { info: "Filtered not IT vacancy with id=#{vacancy_id}" }
        end

        HhRuRecord.create!(
          id: @payload['id'],
          title: @payload['name'],
          company_name: employer_name
        )

        { message: formatter.format_message }
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

      def it_vacancy?
        it_specs = @payload['specializations'].select do |spec|
          spec['profarea_id'] == '1' &&
            !%w[Продажи Контент Маркетинг].include?(spec['name'])
        end

        it_specs.any?
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

      def employer_name
        @payload.dig('employer', 'name')
      end

      def company
        city = @payload.dig('address', 'city') || @payload.dig('area', 'name')

        [employer_name, city].compact.join ', '
      end

      # Removing all html tags from original description
      def description
        @payload['description']&.gsub(%r{</?[^>]+?>}, '')
      end

      def key_skills
        @payload['key_skills']&.map { |skill| skill['name'] }&.join(', ')
      end
    end
  end
end
