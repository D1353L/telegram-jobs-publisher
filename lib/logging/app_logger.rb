# frozen_string_literal: true

module Telegram
  module JobsPublisher
    class AppLogger < Logger
      PROGNAME = 'TelegramJobsPublisher'

      def initialize(*args)
        super(*args, progname: PROGNAME)
      end
    end
  end
end
