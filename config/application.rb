require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
# require "active_record/railtie"
# require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
# require "action_mailbox/engine"
# require "action_text/engine"
require "action_view/railtie"
# require "action_cable/engine"
require "sprockets/railtie"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

if ENV["VCAP_SERVICES"]
  services = JSON.parse(ENV["VCAP_SERVICES"])

  if services.key?("user-provided")
    # Extract UPSes and pull out secrets configs
    user_provided_services = services["user-provided"].select { |s| s["name"].include?("secrets") }
    credentials = user_provided_services.map { |s| s["credentials"] }.reduce(:merge)

    # Take each credential and assign to ENV
    credentials.each do |k, v|
      # Don't overwrite existing env vars
      ENV[k.upcase] ||= v
    end
  end
end

module FindDataBeta
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1

    # Make `form_with` generate non-remote forms.
    config.action_view.form_with_generates_remote_forms = false

    # Using a sass css compressor causes a scss file to be processed twice
    # (once to build, once to compress) which breaks the usage of "unquote"
    # to use CSS that has same function names as SCSS such as max.
    # https://github.com/alphagov/govuk-frontend/issues/1350
    config.assets.css_compressor = nil

    config.action_dispatch.rescue_responses["Datafile::DatafileNotFound"] = :not_found
    config.action_dispatch.rescue_responses["Dataset::DatasetNotFound"] = :not_found
    config.exceptions_app = routes

    config.analytics_tracking_id = ENV["GA_TRACKING_ID"]
    config.i18n.load_path += Dir[Rails.root.join("config/locales/**/**/*.{rb,yml}")]
    config.filter_parameters << :password
    config.filter_parameters << :password_confirmation

    config.elasticsearch = config_for(:opensearch)

    config.ssl_options = { hsts: { expires: 1.week } }

    config.action_dispatch.default_headers = {
      "X-Frame-Options" => "DENY",
      "X-Content-Type-Options" => "nosniff",
      "X-XSS-Protection" => "1; mode=block",
      "X-Download-Options" => "noopen",
      "X-Permitted-Cross-Domain-Policies" => "none",
      "Referrer-Policy" => %w[origin-when-cross-origin strict-origin-when-cross-origin],
    }
  end
end
