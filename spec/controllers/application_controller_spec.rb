# frozen_string_literal: true

require_relative './shared_bot_config.rb'

describe ApplicationController, telegram_bot: :rack do
  include_context 'shared bot config'

  subject { described_class.new }

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
