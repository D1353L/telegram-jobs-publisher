# frozen_string_literal: true

# Configuration file for the resque-web service
# Example:
# $ resque-web -p 8282 config/resque_web_config.rb

require 'require_all'
require_all 'app/jobs'

require 'resque'
require 'resque-scheduler'
require 'resque/scheduler/server'
