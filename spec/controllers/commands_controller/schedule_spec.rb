# frozen_string_literal: true

require_relative '../shared_bot_config.rb'

describe 'CommandsController#schedule!', telegram_bot: :rack do
  include_context 'shared bot config'

  subject { described_class.new }

  context 'params' do
    context 'valid parameter' do
      %w[1h 1.4h 22.555h 1m 2.6m 4.777m].each do |param|
        it "passes #{param}" do
          allow(ScheduleService).to receive(:schedule!).with(param)
          allow(ScheduleService).to receive(:status)

          dispatch_command(:schedule, param)

          expect(ScheduleService).to have_received(:schedule!).with(param)
          expect(ScheduleService).to have_received(:status)
        end
      end
    end

    context 'invalid parameter' do
      it "doesn't pass" do
        invalid_param = '4w'
        allow(ScheduleService).to receive(:schedule!).with(invalid_param)

        dispatch_command(:schedule, invalid_param)

        expect(ScheduleService).to_not have_received(:schedule!)
          .with(invalid_param)
      end
    end

    context 'multiple params' do
      it "doesn't pass" do
        params = %w[1h 2m]
        allow(ScheduleService).to receive(:schedule!)

        dispatch_command(:schedule, *params)

        expect(ScheduleService).to_not have_received(:schedule!)
      end
    end

    context 'no params' do
      it 'uses default value' do
        default_value = '1h'
        ENV['DEFAULT_SCHEDULE_VALUE'] = default_value
        allow(ScheduleService).to receive(:schedule!).with(default_value)
        allow(Sidekiq).to receive(:get_schedule)
          .and_return({ every: default_value })

        dispatch_command(:schedule)

        expect(ScheduleService).to have_received(:schedule!).with(default_value)
      end
    end
  end

  it 'responds with schedule status' do
    status = 'test status'
    allow(ScheduleService).to receive(:schedule!)
    allow(ScheduleService).to receive(:status).and_return(status)

    expect { dispatch_command(:schedule, '1h') }
      .to make_telegram_request(bot, :sendMessage)
      .with(hash_including(text: status))
  end
end
