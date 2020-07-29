# telegram-jobs-publisher
The application to publish last vacancies from different services to Telegram-channel.

# Setup and run
This is not a Rails app, just Rack.

1. Fill up all required configs in the .env (Requires existing Telegram-bot api_key and Telegram-channel name)
2. rake db:create && rake db:migrate
3. bundle exec sidekiq -r ./config/sidekiq_boot.rb -c 5
4. In a separate command line - ruby config.ru
