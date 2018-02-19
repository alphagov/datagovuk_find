class MessagesController < ApplicationController

  def acknowledge_and_redirect
    session[:beta_message] = true

    if click_from_search_page?
      redirect_to search_path(q: params[:q])
    else
      redirect_to referrer
    end

  end

  private

  def referrer
    Rails.application.routes.recognize_path(request.referrer)
  end

  def click_from_search_page?
    referrer[:controller] == 'search' && referrer[:action] == 'search'
  end
end
