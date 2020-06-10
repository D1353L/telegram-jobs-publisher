# frozen_string_literal: true

require_relative '../shared_bot_config.rb'

describe 'CommandsController#reset!', telegram_bot: :rack do
  include_context 'shared bot config'

  subject { described_class.new }

  let(:status) { 'test status' }

  before do
    allow(ScheduleService).to receive(:reset!)
    allow(ScheduleService).to receive(:status).and_return(status)
  end

  it 'resets schedule' do
    dispatch_command(:reset)

    expect(ScheduleService).to have_received(:reset!)
  end

  it 'responds with schedule status' do
    expect { dispatch_command(:reset) }
      .to make_telegram_request(bot, :sendMessage)
      .with(hash_including(text: status))
  end
end
