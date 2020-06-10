# frozen_string_literal: true

describe ScheduleService do

  subject { described_class }

  context '#schedule!' do
    it 'schedules PublishWorker' do
      every = '1h'

      allow(Sidekiq).to receive(:set_schedule)

      subject.schedule! every

      expect(Sidekiq).to have_received(:set_schedule).with(
        ScheduleService::SCHEDULE_NAME,
        {
          class: PublishWorker.to_s,
          args: 'APIClient::HhRu',
          every: every
        }
      )
    end
  end

  context 'reset!' do
    let(:scheduled_set) { double('Sidekiq::ScheduledSet.new') }
    let(:all_queues) { double('Sidekiq::Queue.all') }
    let(:retry_set) { double('Sidekiq::RetrySet.new') }

    before do
      allow(Sidekiq).to receive(:remove_schedule)
      allow(Sidekiq::ScheduledSet).to receive(:new).and_return(scheduled_set)
      allow(Sidekiq::Queue).to receive(:all).and_return(all_queues)
      allow(Sidekiq::RetrySet).to receive(:new).and_return(retry_set)

      allow(scheduled_set).to receive(:clear)
      allow(all_queues).to receive(:each)
      allow(retry_set).to receive(:clear)
    end

    before { ScheduleService.reset! }

    it 'removes the schedule' do
      expect(Sidekiq).to have_received(:remove_schedule)
        .with(ScheduleService::SCHEDULE_NAME)
    end

    it 'clears the schedule set' do
      expect(scheduled_set).to have_received(:clear)
    end

    it 'clears queues' do
      expect(all_queues).to have_received(:each) do |&block|
        expect(block).to be(Proc.new(&:clear))
      end
    end

    it 'clears the retry set' do
      expect(retry_set).to have_received(:clear)
    end
  end

  context 'status' do
    context 'when schedule present' do
      it 'responds with message that worker scheduled every' do
        every = '1h'
        allow(Sidekiq).to receive(:get_schedule)
          .with(ScheduleService::SCHEDULE_NAME).and_return({ 'every' => every })

        expect(ScheduleService.status).to eq "Worker scheduled every #{every}"
      end
    end

    context 'when schedule is not present' do
      it 'responds with message that worker is not scheduled' do
        allow(Sidekiq).to receive(:get_schedule)
          .with(ScheduleService::SCHEDULE_NAME).and_return(nil)

        expect(ScheduleService.status).to eq 'Worker is not scheduled'
      end
    end
  end
end
