# frozen_string_literal: true

describe JobAdFormatter do
  subject { described_class }

  let(:vacancy_payload) do
    JSON.parse(File.read('spec/fixtures/vacancy_valid_response.json'))
  end
  let(:vacancy_description_sanitized) do
    vacancy_payload['description']&.gsub(%r{</?[^>]+?>}, '')
  end
  let(:formatter_instance) do
    described_class.new(
      title: vacancy_payload['name'],
      company: 'Мевикс, Краснодар',
      experience: vacancy_payload.dig('experience', 'name'),
      salary: 'от 20000 до 30000 руб.',
      description: vacancy_description_sanitized,
      skills: 'SMM, Наполнение контентом, Написание текстов, Копирайтинг, '\
      'Креативность, Грамотность, понимание потребностей аудитории',
      link: vacancy_payload['alternate_url'],
      published_at: vacancy_payload['published_at']
    )
  end

  let(:formatted_vacancy) { File.read('spec/fixtures/formatted_vacancy.txt') }

  describe '#format_message' do
    it 'formats message' do
      expect(formatter_instance.format_message).to eq(formatted_vacancy)
    end

    it 'complies with max message length' do
      expect(formatter_instance.format_message.length)
        .to be <= JobAdFormatter::MAX_MESSAGE_LENGTH
    end
  end
end
