# frozen_string_literal: true

RSpec.configure do |rspec|
  rspec.shared_context_metadata_behavior = :apply_to_host_groups
end

RSpec.shared_context 'shared bot config', shared_context: :metadata do

  let(:request_path) { '/telegram' }
  let(:bot) { Telegram::Bot::ClientStub.new('TestBot') }

  let(:app) do
    path = request_path
    bot_app = Telegram::Bot::Middleware.new(bot, CommandsController)
    app = Rack::Builder.new do
      map(path) { run bot_app }
      run ->(env) { raise "Route is not mapped: #{env['PATH_INFO']}" }
    end
    app
  end

  let(:logger) do
    instance_double('LoggersPool', debug: true, info: true, error: true)
  end

  before(:all) do
    Telegram.bots_config = {
      default: {}
    }
  end

  before do
    Telegram.instance_variable_set(:@logger, logger)
    Telegram.class.send(:attr_reader, :logger)
  end

  after do
    Telegram.remove_instance_variable(:@logger)
  end
end

RSpec.configure do |rspec|
  rspec.include_context 'shared bot config', include_shared: true
end
