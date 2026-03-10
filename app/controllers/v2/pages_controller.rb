module V2
  class PagesController < ApplicationController
    def home
      expires_in 30.minutes, public: true
      render layout: "v2/layouts/application"
    end

    def components
      base_visualisations_path = Rails.root.join("app/content/data/")
      @average_house_prices = JSON.parse(File.read(base_visualisations_path.join("average_house_prices/average_house_prices.json")))
      @fuel_and_oil_prices = JSON.parse(File.read(base_visualisations_path.join("fuel_and_oil_prices/fuel_and_oil_prices.json")))
      render layout: "v2/layouts/application"
    end

    def cookies
      render layout: "v2/layouts/application"
    end

    def content_page
      rendered_content = Dgu::Markdown.render_from_file(
        Rails.configuration.x.markdown_content_pages_location,
        params[:slug],
      )
      template = params.fetch("template", "v2/pages/content_page")
      # NOTE: the below brakeman complaint is happening because brakeman is assuming the parameter is part of the URL.
      #   In this case, the parameter is specified in a single URL as a default value - so not dynamically settable by users.
      # brakeman: ignore: Dynamic Render Path (reason: template is fetched from a constant defined as a default parameter in routes.rb)
      render layout: "v2/layouts/application", template: template, locals: {
        rendered_content: rendered_content,
        title: params[:title],
      }
    end
  end
end
