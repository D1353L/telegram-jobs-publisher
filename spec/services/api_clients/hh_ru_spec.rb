# frozen_string_literal: true

describe APIClient::HhRu do
  subject { described_class }

  let(:vacancy_id) { 1 }
  let(:vacancies_response) do
    double(HTTParty::Response, code: 200, items: [{ 'id' => vacancy_id }])
  end
  let(:vacancy_error_response) { double(HTTParty::Response, code: 403) }
  let(:vacancy_valid_response) do
    JSON.parse(File.read('spec/fixtures/vacancy_valid_response.json'))
  end

  describe '#create_job_ad!' do
    context 'processing errors' do
      context 'got error on getting vacancies' do
        before do
          stub_request(:any, 'api.hh.ru/vacancies')
            .with(query: hash_including({}))
            .to_return(status: [401, 'Forbidden'])
        end

        it 'returns error message' do
          expect(subject.create_job_ad!)
            .to eq({ error: 'Unable to fetch vacancy id' })
        end
      end

      context 'got error on getting vacancy' do
        before do
          allow(subject).to receive(:get)
            .with('/vacancies', query: JSON.parse(ENV['HH_RU_VACANCIES_PARAMS']))
            .and_return(vacancies_response)

          allow(vacancies_response).to receive(:[])
            .with('items').and_return(vacancies_response.items)

          allow(subject).to receive(:get)
            .with("/vacancies/#{vacancy_id}")
            .and_return(vacancy_error_response)
        end

        it 'returns error message' do
          expect(subject.create_job_ad!)
            .to eq({ error: "Unable to fetch vacancy with id=#{vacancy_id}" })
        end
      end
    end

    context 'processing when vacancy is already published' do
      before do
        allow(subject).to receive(:get)
          .with('/vacancies', query: JSON.parse(ENV['HH_RU_VACANCIES_PARAMS']))
          .and_return(vacancies_response)

        allow(vacancies_response).to receive(:[])
          .with('items').and_return(vacancies_response.items)

        allow(subject).to receive(:vacancy)
          .with(vacancy_id)
          .and_return(vacancy_valid_response)

        HhRuRecord.create!(
          id: vacancy_valid_response['id'],
          title: vacancy_valid_response['name'],
          company_name: vacancy_valid_response.dig('employer', 'name')
        )
      end

      it 'returns info message' do
        expect(subject.create_job_ad!)
          .to eq({ info: 'The vacancy is already published' })
      end
    end

    context 'processing when vacancy is new' do
      let(:formatted_vacancy) { File.read('spec/fixtures/formatted_vacancy.txt') }
      
      before do
        allow(subject).to receive(:get)
          .with('/vacancies', query: JSON.parse(ENV['HH_RU_VACANCIES_PARAMS']))
          .and_return(vacancies_response)

        allow(vacancies_response).to receive(:[])
          .with('items').and_return(vacancies_response.items)

        allow(subject).to receive(:vacancy)
          .with(vacancy_id)
          .and_return(vacancy_valid_response)
      end

      it 'saves vacancy to DB' do
        subject.create_job_ad!

        expect(HhRuRecord.last.id).to eq vacancy_valid_response['id'].to_i
        expect(HhRuRecord.last.title).to eq vacancy_valid_response['name']
        expect(HhRuRecord.last.company_name)
          .to eq vacancy_valid_response.dig('employer', 'name')
      end

      it 'returns formatted vacancy' do
        expect(subject.create_job_ad!)
          .to eq({ message: formatted_vacancy })
      end
    end
  end
end
