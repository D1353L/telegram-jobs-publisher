# frozen_string_literal: true

describe Telegram::JobsPublisher::ChatLogger do
  subject { described_class }
  let(:instance) { subject.new(chat_id: 0, message_sender: nil) }

  describe '#new' do
    it 'creates new instance' do
      expect { subject.new(chat_id: 0, log_level: :info, message_sender: nil) }
        .not_to raise_error
    end

    it "has default 'info' log level" do
      expect(instance.instance_variable_get(:@chat_log_level))
        .to eq Telegram::JobsPublisher::ChatLogger::LOG_LEVELS[:info]
    end
  end

  describe '#set_level' do
    it 'changes the log level if valid param' do
      instance.set_level(:debug)

      expect(instance.instance_variable_get(:@chat_log_level))
        .to eq Telegram::JobsPublisher::ChatLogger::LOG_LEVELS[:debug]
    end

    it 'not changes the log level if invalid param' do
      instance.set_level(:smth)

      expect(instance.instance_variable_get(:@chat_log_level))
        .to eq Telegram::JobsPublisher::ChatLogger::LOG_LEVELS[:info]
    end
  end

  describe '#human_log_level' do
    it 'returns string representation of the log level value' do
      expect(instance.human_log_level).to eq 'info'
    end
  end

  describe '#info' do
    before(:each) do
      allow(instance).to receive(:send_message)
    end

    context 'log level is :info' do
      it 'sends message' do
        instance.set_level :info
        instance.info('message')

        expect(instance).to have_received(:send_message)
      end
    end

    context 'log level is :error' do
      it 'sends message' do
        instance.set_level :error
        instance.info('message')

        expect(instance).to have_received(:send_message)
      end
    end

    context 'log level is :debug' do
      it 'sends message' do
        instance.set_level :debug
        instance.info('message')

        expect(instance).to have_received(:send_message)
      end
    end
  end

  describe '#error' do
    before(:each) do
      allow(instance).to receive(:send_message)
    end

    context 'log level is :info' do
      it "doesn't send message" do
        instance.set_level :info
        instance.error('message')

        expect(instance).to_not have_received(:send_message)
      end
    end

    context 'log level is :error' do
      it 'sends message' do
        instance.set_level :error
        instance.error('message')

        expect(instance).to have_received(:send_message)
      end
    end

    context 'log level is :debug' do
      it 'sends message' do
        instance.set_level :debug
        instance.error('message')

        expect(instance).to have_received(:send_message)
      end
    end
  end

  describe '#debug' do
    before(:each) do
      allow(instance).to receive(:send_message)
    end

    context 'log level is :info' do
      it "doesn't send message" do
        instance.set_level :info
        instance.debug('message')

        expect(instance).to_not have_received(:send_message)
      end
    end

    context 'log level is :error' do
      it "doesn't send message" do
        instance.set_level :error
        instance.debug('message')

        expect(instance).to_not have_received(:send_message)
      end
    end

    context 'log level is :debug' do
      it 'sends message' do
        instance.set_level :debug
        instance.debug('message')

        expect(instance).to have_received(:send_message)
      end
    end
  end
end
