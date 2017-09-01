require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module FindDataBeta
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1
    config.assets.initialize_on_precompile = false
    config.exceptions_app = self.routes

    config.analytics_tracking_id = ENV['GA_TRACKING_ID']
    config.analytics_test_tracking_id = ENV['GA_TEST_TRACKING_ID']

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
  end
end
