# frozen_string_literal: true

require 'httparty'
require 'rss'

module APIClient
  class DouUa
    include ::HTTParty
    base_uri 'jobs.dou.ua'

    class << self
      def create_job_ad!
        @payload = vacancy
        found_record = DouUaRecord.find_by(
          'LOWER(title)= ? AND LOWER(company_name) = ?',
          title.downcase, company.downcase
        )

        return { info: 'The vacancy is already published' } if found_record

        DouUaRecord.create!(
          title: title,
          company_name: company
        )

        { message: formatter.format_message }
      end

      private

      def vacancy
        response = get('/vacancies/feeds/?remote')
        return [] if response.code != 200

        rss = RSS::Parser.parse(response.body)

        rss.items.first
      end

      def formatter
        JobAdFormatter.new(
          title: title,
          company: company,
          experience: nil,
          salary: salary,
          description: description,
          skills: nil,
          link: link,
          published_at: @payload.pubDate
        )
      end

      def title
        @payload.title.split(' в ').first
      end

      def company
        values = @payload.title.split(' в ')[1].split(', ')

        values.delete_if { |v| /\d/.match(v) || v == 'удаленно' }

        values.join(', ')
      end

      def salary
        val = @payload.title.split(', ')[1]
        /\d/.match(val) ? val : 'з/п не указана'
      end

      def description
        desc = APIClient::Helper.sanitize_html(@payload.description)
        desc.sub("Откликнуться на вакансию\n", '').strip
      end

      def link
        @payload.link.sub('?utm_source=jobsrss', '')
      end
    end
  end
end
