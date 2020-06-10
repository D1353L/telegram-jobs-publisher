# frozen_string_literal: true

describe Telegram::JobsPublisher::LoggersPool do
  subject { described_class }

  let(:instance) do
    subject.new(
      loggers: {
        file_logger: Telegram::JobsPublisher::ChatLogger.new(chat_id: 0),
        stdout_logger: Logger.new($stdout)
      },
      progname: 'test_progname'
    )
  end

  describe '#new' do
    it 'sets loggers' do
      expect(instance.instance_variable_get(:@loggers))
        .to be_an_instance_of(Hash)
      expect(instance.instance_variable_get(:@loggers).keys)
        .to match_array(%i[file_logger stdout_logger])
      expect(instance.instance_variable_get(:@loggers).values)
        .not_to include(be_nil)
    end

    it 'sets progname for each logger' do
      prognames = instance.instance_variable_get(:@loggers).values.map(&:progname)
      expect(prognames).to all(be 'test_progname')
    end
  end

  describe '#info #debug #error #warn #debug?' do
    before do
      @loggers = instance.instance_variable_get(:@loggers).values
      @loggers.each do |logger|
        allow(logger).to receive(:send)
      end
    end

    %i[info debug error warn debug?].each do |method_name|
      it "calls #{method_name} for each logger" do
        instance.send(method_name)
        @loggers.each do |logger|
          expect(logger).to have_received(:send).with(method_name)
        end
      end
    end
  end

  describe '#[]' do
    it 'returns logger by key' do
      loggers_h = instance.instance_variable_get(:@loggers)

      loggers_h.each_pair do |k, v|
        expect(instance[k]).to eq v
      end
    end
  end

  describe '#[]=' do
    it 'sets logger value' do
      logger_value = Logger.new(nil)
      instance[:new_logger] = logger_value
      loggers_h = instance.instance_variable_get(:@loggers)

      expect(loggers_h[:new_logger]).to eq logger_value
    end
  end

  describe '#each' do
    it 'executes block for each logger' do
      loggers = instance.instance_variable_get(:@loggers).values
      loggers.each do |logger|
        allow(logger).to receive(:info)
      end

      instance.each { |l| l.info('msg') }

      loggers.each do |logger|
        expect(logger).to have_received(:info)
      end
    end
  end
end
