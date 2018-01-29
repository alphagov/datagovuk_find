class HomeController < LoggedAreaController
  before_action :toggle_beta_message

  def accept_and_redirect
    session[:beta_message] = true
    redirect_to root_path
  end

  private

  def toggle_beta_message
    flash[:beta_message] =
      beta_message_unseen? ? 'show' : 'hide'
  end
end
