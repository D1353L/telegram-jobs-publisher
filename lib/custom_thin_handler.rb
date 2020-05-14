# frozen_string_literal: true

class CustomThinHandler < Rack::Handler::Thin
  def self.run(*)
    super
    Telegram.logger.info 'Server is stopped'
  end
end
