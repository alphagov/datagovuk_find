class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception, prepend: true
  before_action :set_raven_context
  before_action :toggle_beta_message

private

  def set_raven_context
    Raven.extra_context(params: params.to_unsafe_h,
                        url: request.url,
                        environment: Rails.env,
                        app: ENV['VCAP_APPLICATION'])
  end

  def toggle_beta_message
    flash[:beta_message] =
      beta_message_unseen? ? 'show' : 'hide'
  end

  def beta_message_unseen?
    !session.key?('beta_message') || session[:beta_message] == false
  end
end
