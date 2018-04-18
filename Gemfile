source 'https://rubygems.org'

ruby IO.read('.ruby-version').strip

gem 'rails', '~> 5.1.6'
gem 'pg', '~> 0.18'
gem 'puma', '~> 3.7'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'jbuilder', '~> 2.5'
gem 'govuk_elements_rails'
gem 'govuk_template'
gem 'kaminari', '~> 1.0.1'
gem 'rest-client', '~> 2.0.2'
gem 'mime-types', '~> 3.1'
gem 'friendly_id', '~> 5.2.1'
gem "elasticsearch", "~> 5.0.4"
gem "elasticsearch-model", "~> 5.0.1"
gem "elasticsearch-rails", "~> 5.0.1"
gem "elasticsearch-persistence", "~> 5", require: "elasticsearch/persistence/model"
gem 'elasticsearch-dsl', "~> 0.1.5"
gem 'htmlentities', '~> 4.3'
gem 'secure_headers', '~> 5.0'
gem 'faraday'
gem 'faraday_middleware'
gem 'sentry-raven'
gem 'lograge', '~> 0.10'
gem 'logstash-event', '~> 1.2'
gem 'zendesk_api'
gem 'parslet'
gem 'gds_metrics', '~> 0.0.2'
gem 'redcarpet', '~> 3.4'
gem 'jquery-rails'
gem 'browser', '~> 2.5.3'

group :development, :test do
  gem 'byebug', '~> 9'
  gem 'pry', '~> 0.10'
  gem 'pry-byebug', '~> 3.4'
  gem 'pry-stack_explorer', '~> 0.4.9'
  gem 'dotenv', '~> 2.2'
  gem 'rspec-rails', '~> 3.6'
  gem 'rspec', '~> 3.6'
  gem 'webmock'
  gem 'dotenv-rails', '~> 2.2'
  gem 'brakeman', '~> 4.2'
end

group :development do
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring', '~> 2.0'
  gem 'spring-commands-rspec'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'guard'
  gem 'guard-rspec'
  gem 'launchy'
end

group :test do
  gem 'simplecov', '~> 0.13'
  gem 'codeclimate-test-reporter', '~> 1.0.0'
  gem 'capybara', '~> 2.15.1'
  gem 'capybara-selenium', '0.0.6'
  gem 'chromedriver-helper', '~> 1.1'
end

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
