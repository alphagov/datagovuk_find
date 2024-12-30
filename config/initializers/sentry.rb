require "sentry-ruby"
require "sentry-rails"

Sentry.init do |config|
  config.dsn = ENV["SENTRY_DSN"] if ENV["SENTRY_DSN"]
end
