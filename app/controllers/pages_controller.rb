class PagesController < ApplicationController
  before_action :check_consent, only: [:support]

  def terms
  end

  def privacy
  end

  def cookies
  end

  def support
  end

  def accessibility
  end

  private

  def check_consent
    return if Rails.env.test?
    redirect_to new_consent_path if has_not_consented?
  end

  def has_not_consented?
    !session.key?('consent') || session[:consent] == false
  end

end
