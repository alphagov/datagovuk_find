require Rails.root.join("app/services/dgu/markdown")

module V2
  class DataManualController < ApplicationController
    def home
      expires_in 30.minutes, public: true
      render layout: "v2/layouts/data_manual"
    end

    def content
      expires_in 30.minutes, public: true
      data_manual_markdown_directory = Rails.configuration.x.markdown_data_manual_location
      safe_slug = params[:slug].parameterize
      markdown_file = Rails.root.join(data_manual_markdown_directory, "#{safe_slug}.md")
      if File.exist?(markdown_file)
        markdown = File.read(markdown_file)
      else
        render_not_found && return
      end
      rendered_content = Dgu::Markdown.render(markdown).html_safe

      data_manual_pages = @data_manual_pages.deep_dup
      data_manual_pages.each do |data_manual_item|
        if data_manual_item[:slug] == safe_slug
          data_manual_item[:selected] = true
        end
      end

      render layout: "v2/layouts/data_manual", locals: {
        rendered_content: rendered_content,
        data_manual_pages: data_manual_pages
      }
    end
  end
end
