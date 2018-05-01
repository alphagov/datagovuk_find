class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception, prepend: true
  before_action :set_raven_context

private

  def set_raven_context
    Raven.extra_context(params: params.to_unsafe_h,
                        url: request.url,
                        environment: Rails.env,
                        app: ENV['VCAP_APPLICATION'])
  end
end
