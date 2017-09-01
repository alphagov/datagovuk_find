class ErrorsController < ApplicationController
  skip_before_action :authenticate, only: [:not_authenticated]

  def not_found
    render(status: 404)
  end

  def internal_server_error
    render(status: 500)
  end

  def not_authenticated
    render(status: 401)
  end
end
