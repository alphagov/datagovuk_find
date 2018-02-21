require 'private_beta_user'

class LoggedAreaController < ApplicationController
  before_action :check_consent
  before_action :authenticate

  def check_consent
    return if Rails.env.test?
    redirect_to new_consent_path if has_not_consented?
  end

  def authenticate
    return if Rails.env.test? || !ENV['PRIVATE_BETA_USER_SALT']

    authenticate_or_request_with_http_basic('Please sign in with username and password provided to you') do |username, password|
      if admin_login?(username, password)
        return true
      end

      if beta_login?(username, password)
        session[:beta_user] = username
        return true
      end

      redirect_to '/not_authenticated'
    end
  end

  private

  def admin_login?(username, password)
    username == ENV['HTTP_USERNAME'] && password == ENV['HTTP_PASSWORD']
  end

  def beta_login?(username, password)
    PrivateBetaUser.authenticate?(username, password)
  end

  def has_not_consented?
    !session.key?('consent') || session[:consent] == false
  end
end
