class MessagesController < ApplicationController

  def acknowledge
    session[:beta_message] = true
    redirect_back(fallback_location: root_path)
  end
end
