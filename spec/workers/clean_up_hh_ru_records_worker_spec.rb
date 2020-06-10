# frozen_string_literal: true

describe CleanUpHhRuRecordsWorker do
  subject { described_class.new }

  before do
    20.times do |i|
      HhRuRecord.create!(
        id: i+1,
        title: FFaker::LoremRU.sentence,
        company_name: FFaker::Company.name
      )
    end
  end

  context '#perform' do
    context 'records count > n' do
      it 'cleans up HhRuRecords but leaves last n' do
        expect(HhRuRecord.count).to eq 20
        allow(subject.logger).to receive(:info)

        subject.perform(5)

        expect(HhRuRecord.count).to eq 5
        expect(HhRuRecord.pluck(:id)).to match_array((16..20).to_a)
        expect(subject.logger).to have_received(:info)
      end
    end

    context 'records count == n' do
      it 'does nothing' do
        expect(HhRuRecord.count).to eq 20

        subject.perform(20)

        expect(HhRuRecord.count).to eq 20
      end
    end

    context 'records count < n' do
      it 'does nothing' do
        expect(HhRuRecord.count).to eq 20

        subject.perform(40)

        expect(HhRuRecord.count).to eq 20
      end
    end
  end
end
