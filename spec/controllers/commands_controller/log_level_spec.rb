# frozen_string_literal: true

require_relative '../shared_bot_config.rb'

describe 'CommandsController#log_level!', telegram_bot: :rack do
  include_context 'shared bot config'

  subject { described_class.new }

  let(:chat_logger) do
    instance_double('ChatLogger', human_log_level: 'log level')
  end

  before do
    allow(logger).to receive(:[]).with(:chat_logger).and_return(chat_logger)
  end

  context 'params' do
    context 'valid parameter' do
      %w[info error debug].each do |param|
        before do
          allow(chat_logger).to receive(:set_level).with(param)
        end

        it "sets log level with #{param}" do
          dispatch_command(:log_level, param)

          expect(chat_logger).to have_received(:set_level).with(param)
        end

        it "responds with message that log level set to #{param}" do
          expect { dispatch_command(:log_level, param) }
            .to make_telegram_request(bot, :sendMessage)
            .with(hash_including(text: "Log level is set to #{param}"))
        end
      end
    end

    context 'invalid parameter' do
      it "doesn't pass" do
        invalid_param = 'invalid'
        allow(chat_logger).to receive(:set_level).with(invalid_param)

        dispatch_command(:log_level, invalid_param)

        expect(chat_logger).to_not have_received(:set_level)
          .with(invalid_param)
      end
    end

    context 'multiple params' do
      it "doesn't pass" do
        params = %w[debug error]
        allow(chat_logger).to receive(:set_level)

        dispatch_command(:log_level, *params)

        expect(chat_logger).to_not have_received(:set_level)
      end
    end

    context 'no params' do
      it 'returns current log level' do
        expect { dispatch_command(:log_level) }
          .to make_telegram_request(bot, :sendMessage)
          .with(hash_including(text: 'log level'))
      end
    end
  end
end
