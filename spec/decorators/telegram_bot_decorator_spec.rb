# frozen_string_literal: true

describe TelegramBotDecorator do
  subject { TelegramBotDecorator }

  describe '#silent_time?' do
    before do
      time = Time.new(2020, 5, 10, 11, 0, 0)
      allow(Time).to receive(:now).and_return(time)
    end

    context 'from < to' do
      context 'including current time' do
        it { expect(subject.silent_time?(10, 12)).to eq true }
      end

      context 'excluding current time' do
        it { expect(subject.silent_time?(8, 10)).to eq false }
      end

      context 'from == current hour' do
        it { expect(subject.silent_time?(11, 13)).to eq true }
      end

      context 'to == current hour' do
        it { expect(subject.silent_time?(10, 11)).to eq false }
      end
    end

    context 'from > to' do
      context 'including current time' do
        it { expect(subject.silent_time?(23, 12)).to eq true }
      end

      context 'excluding current time' do
        it { expect(subject.silent_time?(23, 10)).to eq false }
      end

      context 'from == current hour' do
        it { expect(subject.silent_time?(11, 5)).to eq true }
      end

      context 'to == current hour' do
        it { expect(subject.silent_time?(23, 11)).to eq false }
      end
    end

    context 'from == to' do
      context 'including current time' do
        it { expect(subject.silent_time?(11, 11)).to eq true }
      end

      context 'excluding current time' do
        it { expect(subject.silent_time?(23, 23)).to eq true }
      end
    end
  end
end
