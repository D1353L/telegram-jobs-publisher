# frozen_string_literal: true

require_relative '../shared_bot_config.rb'

describe 'CommandsController#status!', telegram_bot: :rack do
  include_context 'shared bot config'

  subject { described_class.new }

  it 'responds with schedule status' do
    status = 'test status'
    allow(ScheduleService).to receive(:status).and_return(status)

    expect { dispatch_command(:status) }
      .to make_telegram_request(bot, :sendMessage)
      .with(hash_including(text: status))
  end
end
