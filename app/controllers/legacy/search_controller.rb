class Legacy::SearchController < ApplicationController
  def redirect
    filters = {
      format: search_params[:res_format],
      publisher: search_params[:publisher],
      licence: licence_param,
    }.compact

    redirect_to search_path(q: search_params[:q], filters:)
  end

private

  def licence_param
    "uk-ogl" if search_params["license_id-is-ogl"] == "true"
  end

  def search_params
    params.permit(
      :q,
      # Legacy filter params
      :res_format,
      :publisher,
      "license_id-is-ogl",
      # Current filter params
      filters: %i[publisher topic format licence_code],
    )
  end
end
