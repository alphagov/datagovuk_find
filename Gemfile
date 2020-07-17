source "https://rubygems.org"

ruby IO.read(".ruby-version").strip

gem "rails", "5.2.4.3"

gem "addressable"
gem "bootsnap"
gem "browser"
gem "elasticsearch"
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
  gem "codeclimate-test-reporter"
  gem "factory_bot"
  gem "govuk_test"
  gem "simplecov"
end
