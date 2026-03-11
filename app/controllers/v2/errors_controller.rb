module V2
  class ErrorsController < ApplicationController
    def not_found
      render status: :not_found, layout: "v2/layouts/application"
    end

    def internal_server_error
      render status: :internal_server_error, layout: "v2/layouts/application"
    end
  end
end
