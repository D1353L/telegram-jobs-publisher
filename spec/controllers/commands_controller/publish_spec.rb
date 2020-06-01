# frozen_string_literal: true

describe 'CommandsController#publish!', telegram_bot: :rack do
  subject { CommandsController.new }

  let(:request_path) { '/telegram' }
  let(:bot) { Telegram::Bot::ClientStub.new('TestBot') }

  let(:app) do
    path = request_path
    bot_app = Telegram::Bot::Middleware.new(bot, CommandsController)
    app = Rack::Builder.new do
      map(path) { run bot_app }
      run ->(env) { raise "Route is not mapped: #{env['PATH_INFO']}" }
    end
    if ActionPack::VERSION::MAJOR >= 5
      app
    else
      require 'action_dispatch/middleware/params_parser'
      ActionDispatch::ParamsParser.new(app)
    end
  end

  let(:logger) do
    instance_double('LoggersPool', debug: true, info: true, error: true)
  end

  before do
    Telegram.instance_variable_set(:@logger, logger)
    Telegram.class.send(:attr_reader, :logger)

    allow(APIClient::HhRu).to receive(:create_job_ad!).and_return({})
  end

  after do
    Telegram.remove_instance_variable(:@logger)
  end

  it 'calls APIClient::HhRu.create_job_ad!' do
    dispatch_command(:publish)
    expect(APIClient::HhRu).to have_received(:create_job_ad!)
  end

  context ':info present in APIClient response' do
    before do
      allow(APIClient::HhRu).to receive(:create_job_ad!)
        .and_return({ info: 'info' })
    end

    it 'responds with info' do
      expect { dispatch_command(:publish) }
        .to make_telegram_request(bot, :sendMessage)
        .with(hash_including(text: 'info'))
    end
  end

  context ':error present in APIClient response' do
    before do
      allow(APIClient::HhRu).to receive(:create_job_ad!)
        .and_return({ error: 'error' })

      dispatch_command(:publish)
    end

    it 'logs an error' do
      expect(Telegram.logger).to have_received(:error).with('error')
    end
  end

  context ':message present in APIClient response' do
    before do
      allow(APIClient::HhRu).to receive(:create_job_ad!)
        .and_return({ message: 'message' })
      allow(TelegramBotDecorator).to receive(:publish_to_channel)
        .and_return(true)
    end

    it 'publishes message to channel' do
      dispatch_command(:publish)

      expect(TelegramBotDecorator).to have_received(:publish_to_channel)
        .with(text: 'message')
    end

    it "responds with 'New vacancy published'" do
      expect { dispatch_command(:publish) }
        .to make_telegram_request(bot, :sendMessage)
        .with(hash_including(text: 'New vacancy published'))
    end
  end
end
