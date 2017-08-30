require 'private_beta_user'

class ApplicationController < ActionController::Base
  before_action :authenticate
  protect_from_forgery with: :exception
end

def authenticate

  return if Rails.env.development? || Rails.env.test?

  httpauth_name = ENV['HTTP_USERNAME']
  httpauth_pass = ENV['HTTP_PASSWORD']

  if !session.key?('consent') || session[:consent] == false
    redirect_to consent_path
  else
    authenticate_or_request_with_http_basic('Administration') do |username, password|
      admin_login = username == httpauth_name && password == httpauth_pass
      beta_login = PrivateBetaUser.authenticate?(username, password)

      if beta_login
        session[:beta_user] = username
      end

      admin_login || beta_login
    end
  end
end
