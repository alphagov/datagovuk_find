require Rails.root.join("app/services/dgu/markdown")

module V2
  class DataManualContentNotFound < ActionController::ActionControllerError
  end

  class DataManualController < ApplicationController
    rescue_from DataManualContentNotFound, with: :render_not_found

    def home
      expires_in 30.minutes, public: true
      render layout: "v2/layouts/data_manual"
    end

    def content
      expires_in 30.minutes, public: true

      render layout: "v2/layouts/data_manual", locals: {
        rendered_content: render_content,
        data_manual_pages: data_manual_pages,
      }
    end

  private

    def render_content
      # The sanitizer is a double protection against attempts to render markdown files
      #   other than the ones in the data manual. The route also specifies the slug parameter
      #   as having the slug constraint
      @sanitizer = Rails::Html::FullSanitizer.new
      safe_slug = @sanitizer.sanitize(params[:slug])
      data_manual_markdown_directory = Rails.configuration.x.markdown_data_manual_location
      # NOTE: the below brakeman complaint is happening because brakeman cannot verify that our config
      #   variable does not contain a leading /.  Ignoring it.
      # brakeman: disable: Rails/DynamicRenderPath, Rails/FileAccess
      markdown_file = Rails.root.join(data_manual_markdown_directory, "#{safe_slug}.md")
      if File.exist?(markdown_file)
        markdown = File.read(markdown_file)
      else
        raise DataManualContentNotFound
      end
      Dgu::Markdown.render(markdown).html_safe
    end

    def data_manual_pages
      data_manual_pages = @data_manual_pages.deep_dup
      data_manual_pages.each do |data_manual_item|
        if data_manual_item[:url] == request.path
          data_manual_item[:selected] = true
        end
      end
      data_manual_pages
    end
  end
end
