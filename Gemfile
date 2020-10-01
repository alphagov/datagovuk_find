source "https://rubygems.org"

gem "rails", "6.0.3.3"

gem "addressable"
gem "bootsnap"
gem "browser"
gem "elasticsearch", "~> 5.0" # gem's major must match db's
gem "elasticsearch-model"
gem "elasticsearch-rails"
gem "faraday"
gem "faraday_middleware"
gem "govuk_elements_rails"
gem "govuk_publishing_components"
gem "htmlentities"
gem "jbuilder"
gem "jquery-rails"
gem "kaminari", "< 1.2"  # do not upgrade this unless elasticsearch is also upgraded
gem "lograge"
gem "logstash-event"
gem "mime-types"
gem "nokogiri"
gem "parslet"
gem "pg"
gem "puma"
gem "redcarpet"
gem "rest-client"
gem "sass-rails"
gem "secure_headers"
gem "sentry-raven"
gem "uglifier"
gem "zendesk_api"

group :development, :test do
  gem "brakeman"
  gem "byebug"
  gem "pry"
  gem "pry-byebug"
  gem "pry-stack_explorer"
  gem "rspec"
  gem "rspec-rails"
  gem "rubocop-govuk"
  gem "webmock"
end

group :development do
  gem "spring"
  gem "spring-commands-rspec"
  gem "spring-watcher-listen"
end

group :test do
  gem "capybara"
  gem "factory_bot"
  gem "govuk_test"
  gem "simplecov", "< 0.18" # see https://github.com/codeclimate/test-reporter/issues/413
end
