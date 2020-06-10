# frozen_string_literal: true

describe PublishWorker do
  subject { described_class.new }

  before do
    allow(TelegramBotDecorator).to receive(:publish_to_channel)
    allow(subject.logger).to receive(:warn)
    allow(subject.logger).to receive(:debug)
  end

  context '#perform' do
    it 'logs error as warn if response contains error' do
      error = 'err'
      allow(APIClient::HhRu).to receive(:create_job_ad!)
        .and_return({ error: error })

      subject.perform('APIClient::HhRu')

      expect(subject.logger).to have_received(:warn).with(error)

      expect(subject.logger).to_not have_received(:debug)
      expect(TelegramBotDecorator).to_not have_received(:publish_to_channel)
    end

    it 'logs info as debug if response contains info' do
      info = 'inf'
      allow(APIClient::HhRu).to receive(:create_job_ad!)
        .and_return({ info: info })

      subject.perform('APIClient::HhRu')

      expect(subject.logger).to have_received(:debug).with(info)

      expect(subject.logger).to_not have_received(:warn)
      expect(TelegramBotDecorator).to_not have_received(:publish_to_channel)
    end

    it 'publishes message to channel if response contains message' do
      message = 'msg'
      allow(APIClient::HhRu).to receive(:create_job_ad!)
        .and_return({ message: message })

      subject.perform('APIClient::HhRu')

      expect(TelegramBotDecorator).to have_received(:publish_to_channel)
        .with({ text: message })

      expect(subject.logger).to_not have_received(:debug)
      expect(subject.logger).to_not have_received(:warn)
    end

    it 'logs error, logs info and publishes to channel if response contains all' do
      response = {
        info: 'inf',
        error: 'err',
        message: 'msg'
      }

      allow(APIClient::HhRu).to receive(:create_job_ad!).and_return(response)

      subject.perform('APIClient::HhRu')

      expect(TelegramBotDecorator).to have_received(:publish_to_channel)
        .with({ text: response[:message] })
      expect(subject.logger).to have_received(:debug).with(response[:info])
      expect(subject.logger).to have_received(:warn).with(response[:error])
    end
  end
end
