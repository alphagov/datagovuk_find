source "https://rubygems.org"

ruby IO.read(".ruby-version").strip

gem "addressable"
gem "browser", "~> 2.5.3"
gem "elasticsearch", "~> 5.0.5"
gem "elasticsearch-model", "~> 5.0.1"
gem "elasticsearch-rails", "~> 7.1.0"
gem "faraday"
gem "faraday_middleware"
gem "govuk_elements_rails"
gem "govuk_publishing_components", "~> 21.60.0"
gem "htmlentities", "~> 4.3"
gem "jbuilder", "~> 2.5"
gem "jquery-rails"
gem "kaminari", "< 1.2"  # do not upgrade this unless elasticsearch is also upgraded
gem "lograge", "~> 0.10"
gem "logstash-event", "~> 1.2"
gem "mime-types", "~> 3.1"
gem "nokogiri"
gem "parslet"
gem "pg", "~> 0.18"
gem "puma", "~> 3.12"
gem "rails", "~> 5.1.6.2"
gem "redcarpet", "~> 3.5"
gem "rest-client", "~> 2.0.2"
gem "sass-rails", "~> 5.0"
gem "secure_headers", "~> 6.3"
gem "sentry-raven"
gem "uglifier", ">= 1.3.0"
gem "zendesk_api"

group :development, :test do
  gem "brakeman", "~> 4.8"
  gem "byebug", "~> 11"
  gem "pry", "~> 0.10"
  gem "pry-byebug", "~> 3.8"
  gem "pry-stack_explorer", "~> 0.4.9"
  gem "rspec", "~> 3.6"
  gem "rspec-rails", "~> 3.6"
  gem "rubocop-govuk"
  gem "webmock", "~> 3.5"
end

group :development do
  gem "spring", "~> 2.0"
  gem "spring-commands-rspec"
  gem "spring-watcher-listen", "~> 2.0.0"
end

group :test do
  gem "capybara", "~> 3.32.1"
  gem "codeclimate-test-reporter", "~> 1.0.0"
  gem "factory_bot"
  gem "govuk_test", "~> 1.0.3"
  gem "simplecov", "~> 0.13", require: false
end
