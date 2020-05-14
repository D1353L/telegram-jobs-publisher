# frozen_string_literal: true

require 'fileutils'

module Telegram
  module JobsPublisher
    class FileLogger < AppLogger
      def initialize(path)
        dir = File.dirname(path)
        FileUtils.mkdir_p(dir) unless File.directory?(dir)
        super
      end
    end
  end
end
