class ErrorsController < PublicAreaController
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
