# frozen_string_literal: true

class LoggingMiddleware
  def initialize(app, logger = nil)
    @app = app
    @logger = logger
  end

  def call(env)
    @app.call(env)
  rescue StandardError => e
    @logger.error e.inspect, e.backtrace
    [200, { 'Content-Type' => 'text/plain' }, ['OK']]
  end
end
