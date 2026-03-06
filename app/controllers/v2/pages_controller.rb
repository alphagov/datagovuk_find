module V2
  class PagesController < ApplicationController
    def home
      expires_in 30.minutes, public: true
      render layout: "v2/layouts/application"
    end

    def components
      render layout: "v2/layouts/application"
    end

    def content_page
      rendered_content = Dgu::Markdown.render_from_file(
        Rails.configuration.x.markdown_content_pages_location,
        params[:slug]
      )
      render layout: "v2/layouts/application", locals: {
        rendered_content: rendered_content,
        title: params[:title],
      }
    end
  end
end
