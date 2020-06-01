# frozen_string_literal: true

describe ApplicationController, telegram_bot: :rack do
  subject { ApplicationController.new }

  let(:logger) do
    instance_double('LoggersPool', debug: true, info: true, error: true)
  end

  before do
    Telegram.instance_variable_set(:@logger, logger)
    Telegram.class.send(:attr_reader, :logger)
  end

  after do
    Telegram.remove_instance_variable(:@logger)
    Telegram.bots_config = nil
  end

  describe '#authorize' do
    context 'whitelist is empty' do
      before do
        allow(subject).to receive(:from).and_return({ id: 3 })
      end

      it { expect { subject.send(:authorize) }.to_not raise_error }
    end

    context 'whitelist is not empty' do
      before do
        Telegram.bots_config = {
          default: {
            whitelist: [1, 2]
          }
        }
      end

      context 'user in whitelist' do
        before do
          allow(subject).to receive(:from).and_return({ id: 1 })
        end

        it { expect { subject.send(:authorize) }.to_not raise_error }
      end

      context 'user is not in whitelist' do
        before do
          allow(subject).to receive(:from).and_return({ id: 3 })
        end

        it {
          expect { subject.send(:authorize) }
            .to raise_error(Telegram::Bot::Forbidden)
        }
      end
    end
  end
end
