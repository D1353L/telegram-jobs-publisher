# frozen_string_literal: true

require 'httparty'

module APIClient
  class HhRu
    include ::HTTParty
    base_uri 'api.hh.ru'

    REQUEST_PARAMS = {
      order_by: 'publication_time',
      schedule: 'remote',
      page: '1',
      per_page: '1'
      # date_from: (DateTime.now - 1 / 24.0).to_s
    }.freeze

    MAX_MESSAGE_LENGTH = 1000

    class << self
      def create_job_ad!
        vacancy_id = vacancies(REQUEST_PARAMS)&.first&.dig('id')
        return nil unless vacancy_id

        @payload = vacancy(vacancy_id)
        return nil unless @payload

        format_message
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

      def format_message
        fields = {
          title: "<b>#{title}</b>\n",
          company: "<i>#{company}</i>\n",
          experience: "Опыт: #{experience}\n\n",
          salary: "<b>#{salary}</b>\n\n",
          skills: "<b>Ключевые навыки:</b> #{skills}\n\n",
          link: link.to_s,
          newline: "\n\n"
        }

        fields_length = fields.values.join.length
        fields[:description] = description(MAX_MESSAGE_LENGTH - fields_length)

        fields.values_at(:title, :company, :experience, :salary, :description,
                         :newline, :skills, :link).join
      end

      def title
        @payload['name']
      end

      def experience
        @payload['experience']['name']
      end

      def salary
        if @payload.dig('salary', 'from')
          from = "от #{@payload['salary']['from']}"
        end
        to = " до #{@payload['salary']['to']}" if @payload.dig('salary', 'to')
        currency = @payload.dig('salary', 'currency')

        return unless from || to

        "#{from}#{to} #{currency}".strip
      end

      def company
        employer_name = @payload.dig('employer', 'name')
        city = @payload.dig('address', 'city') || @payload.dig('area', 'name')

        [employer_name, city].compact.join ', '
      end

      def description(max_length)
        description = @payload['description'].gsub(%r{</?[^>]+?>}, '')
        return description if description.length < max_length

        "#{description[0...max_length - 4]} ..."
      end

      def skills
        @payload['key_skills'].map { |skill| skill['name'] }.join(', ')
      end

      def link
        @payload['alternate_url']
      end
    end
  end
end
