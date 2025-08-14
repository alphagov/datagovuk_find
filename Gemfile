source "https://rubygems.org"

gem "rails", "8.0.2.1"

gem "bootsnap"
gem "browser"
gem "faraday"
gem "faraday_middleware"
gem "govuk_elements_rails"
gem "govuk_publishing_components", "~> 28.7.1" # TODO: Revert https://github.com/alphagov/datagovuk_find/pull/1286 once 39.2.3+
gem "htmlentities"
gem "jquery-rails"
gem "kaminari"
gem "lograge"
gem "logstash-event"
gem "mime-types"
gem "nokogiri"
gem "plek", "~> 4.1" # TODO: unconstrain once govuk_pub_components up-to-date.
gem "puma"
gem "redcarpet"
gem "rsolr"
gem "sass-rails"
gem "secure_headers"
gem "sentry-rails"
gem "sentry-ruby"
gem "sprockets-rails"
gem "uglifier"

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
  gem "simplecov", "< 0.23" # see https://github.com/codeclimate/test-reporter/issues/413
end
