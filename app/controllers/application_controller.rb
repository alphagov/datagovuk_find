class ApplicationController < ActionController::Base
  before_action :authenticate
  protect_from_forgery with: :exception
end

def authenticate
  return if Rails.env.development? || Rails.env.test?

  httpauth_name = ENV['FIND_USERNAME']
  httpauth_pass = ENV['FIND_PASSWORD']
  authenticate_or_request_with_http_basic('Administration') do |username, password|
    username == httpauth_name && password == httpauth_pass
  end
end
