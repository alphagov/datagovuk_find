require 'private_beta_user'

class LoggedAreaController < ApplicationController
  before_action :check_consent
  before_action :authenticate

  def check_consent
    redirect_to use_of_data_path if has_not_consented?
  end

  def authenticate
    return if Rails.env.development? || Rails.env.test?

    authenticate_or_request_with_http_basic('Please sign in with username and password provided to you') do |username, password|
      httpauth_name = ENV['HTTP_USERNAME']
      httpauth_pass = ENV['HTTP_PASSWORD']

      admin_login = username == httpauth_name && password == httpauth_pass
      beta_login = PrivateBetaUser.authenticate?(username, password)

      if beta_login
        session[:beta_user] = username
      end

      if admin_login == false && beta_login == false
        redirect_to '/not_authenticated'
      else
        true
      end
    end
  end

  private

  def has_not_consented?
    !session.key?('consent') || session[:consent] == false
  end
end
