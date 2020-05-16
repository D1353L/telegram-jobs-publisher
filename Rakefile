# frozen_string_literal: true

# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require 'rake'
require 'pry'
require 'dotenv/load'
require 'telegram/bot'
require 'require_all'
require_all 'app'
require_all 'lib'
require_all 'config'
import 'lib/tasks/resque.rake'
