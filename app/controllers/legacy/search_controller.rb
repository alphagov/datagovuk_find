class Legacy::SearchController < ApplicationController
  def redirect
    filters = {
      format: params["res_format"],
      publisher: params["publisher"],
      licence: licence_param
    }.compact

    redirect_to search_path(q: params["q"], filters: filters)
  end

private

  def licence_param
    return "uk-ogl" if params["license_id-is-ogl"] == "true"
  end
end
