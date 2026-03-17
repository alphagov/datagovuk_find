module V2
  class ErrorsController < ApplicationController
    def not_found
      render status: :not_found, layout: "v2/layouts/application"
    end

    def internal_server_error
      render status: :internal_server_error, layout: "v2/layouts/application"
    end

    def internal_server_error_test
      # Deliberately render with a status that does not exist to trigger a real 500
      render status: :non_existent_status
    end
  end
end
