class HomeController < ApplicationController
  skip_before_action :authenticate, only: [:consent, :confirm_consent]

  def index
  end

  def consent
  end

  def confirm_consent
    session[:consent] = true
    redirect_to root_path
  end
end
