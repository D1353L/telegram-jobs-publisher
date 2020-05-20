# frozen_string_literal: true

class JobAdFormatter
  MAX_MESSAGE_LENGTH = 1000

  def initialize(title:, company:, experience:, salary:, description:,
                 skills:, link:, published_at:)
    @title = title
    @company = company
    @experience = experience
    @salary = salary
    @description = description
    @skills = skills
    @link = link
    @published_at = published_at
    @max_description_length = MAX_MESSAGE_LENGTH - initial_fields.values.join.length
    @fields = initial_fields.merge(description: truncate_description)
  end

  def format_message
    @fields.values_at(:title, :company, :experience, :salary, :description,
                      :empty_line, :skills, :link, :published_at).join
  end

  private

  def initial_fields
    {
      title: "<b>#{@title}</b>\n",
      company: "<i>#{@company}</i>\n",
      experience: "Опыт: #{@experience}\n\n",
      salary: "<b>#{@salary}</b>\n\n",
      skills: skills,
      link: "#{@link}\n\n",
      published_at: "Опубликовано на сайте #{published_at}",
      empty_line: "\n\n"
    }
  end

  def truncate_description
    @description.truncate(@max_description_length, separator: '.', omission: ' ...')
  end

  def skills
    "<b>Ключевые навыки:</b> #{@skills}\n\n" if @skills && !@skills.empty?
  end

  def published_at
    DateTime.parse(@published_at).strftime('%d/%m/%Y %H:%M')
  end
end
