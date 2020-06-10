# frozen_string_literal: true

source 'https://rubygems.org'

ruby '2.7.1'

gem 'activerecord'
gem 'pg'
gem 'telegram-bot'
gem 'thin'

gem 'httparty'
gem 'sidekiq-scheduler'

gem 'dotenv'
gem 'require_all'

group :development, :test do
  gem 'pry-byebug'
end

group :test do
  gem 'database_cleaner-active_record'
  gem 'ffaker'
  gem 'rspec'
  gem 'simplecov', require: false
  gem 'webmock'
end
