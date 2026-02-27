require Rails.root.join("app/services/dgu/markdown")

module V2
  class DataManualController < ApplicationController
    def home
      expires_in 30.minutes, public: true
      @collections = []
      render layout: "v2/layouts/data_manual"
    end

    def content
      expires_in 30.minutes, public: true
      @collections = []

      data_manual_markdown_directory = Rails.configuration.x.markdown_data_manual_location
      markdown_file = Rails.root.join(data_manual_markdown_directory, "#{params[:content_slug]}.md")
      if File.exist?(markdown_file)
        markdown = File.read(markdown_file)
      else
        render_not_found && return
      end
      rendered_content = Dgu::Markdown.render(markdown).html_safe

      render layout: "v2/layouts/data_manual", locals: {rendered_content: rendered_content}
    end
  end
end
