# frozen_string_literal: true

require 'dotenv/load'
require 'active_record'
require 'bundler'
require 'require_all'
require_all 'lib/logging'
require_relative 'config/initializers/database_initializer.rb'

task :environment do
  RAKE_PATH = File.expand_path('.')
  RACK_ENV  = ENV.fetch('RACK_ENV', 'development')
  ENV['RAILS_ENV'] = RACK_ENV

  Bundler.require :default, RACK_ENV

  ActiveRecord::Tasks::DatabaseTasks.database_configuration = ActiveRecord::Base.configurations
  ActiveRecord::Tasks::DatabaseTasks.root             = RAKE_PATH
  ActiveRecord::Tasks::DatabaseTasks.env              = RACK_ENV
  ActiveRecord::Tasks::DatabaseTasks.db_dir           = 'db'
  ActiveRecord::Tasks::DatabaseTasks.migrations_paths = ['db/migrate']
  ActiveRecord::Tasks::DatabaseTasks.seed_loader      = OpenStruct.new(load_seed: nil)
end

# Use Rails 6 migrations
load 'active_record/railties/databases.rake'
load 'lib/tasks/dyno_ping.rake'
load 'lib/tasks/publish_vacancy.rake'
