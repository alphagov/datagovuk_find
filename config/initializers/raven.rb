Raven.configure do |config|
  config.dsn = ENV['SENTRY_DSN'] if ENV['SENTRY_DSN']
  config.rails_report_rescued_exceptions = false
  config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s)
end
