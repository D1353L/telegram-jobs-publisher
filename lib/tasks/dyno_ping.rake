desc "Pings WEBHOOK_URL to keep a dyno alive"
task :dyno_ping do
  require "net/http"

  if ENV['WEBHOOK_URL']
    uri = URI(ENV['WEBHOOK_URL'])
    Net::HTTP.get_response(uri)
  end
end
