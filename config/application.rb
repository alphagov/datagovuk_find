require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

if ENV["VCAP_SERVICES"]
  services = JSON.parse(ENV["VCAP_SERVICES"])

  if services.keys.include?('user-provided')
    # Extract UPSes and pull out secrets configs
    user_provided_services = services['user-provided'].select { |s| s['name'].include?('secrets') }
    credentials = user_provided_services.map { |s| s['credentials'] }.reduce(:merge)

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
    config.load_defaults 5.1
    config.assets.initialize_on_precompile = false
    config.action_dispatch.rescue_responses.merge! 'Datafile::DatafileNotFound' => :not_found
    config.action_dispatch.rescue_responses.merge! 'Dataset::DatasetNotFound' => :not_found
    config.exceptions_app = self.routes

    config.analytics_tracking_id = ENV['GA_TRACKING_ID']
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**','**','*.{rb,yml}')]
    config.filter_parameters << :password
    config.filter_parameters << :password_confirmation

    config.elasticsearch = config_for(:elasticsearch)

    config.action_dispatch.default_headers = {
      'X-Frame-Options' => 'DENY',
      'X-Content-Type-Options' => 'nosniff',
      'X-XSS-Protection' => '1; mode=block',
      'X-Download-Options' => 'noopen',
      'X-Permitted-Cross-Domain-Policies' => 'none',
      'Referrer-Policy' => %w(origin-when-cross-origin strict-origin-when-cross-origin)
    }
  end
end
