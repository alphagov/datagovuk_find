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
      data_manual_content_slugs = [
        "who-this-manual-is-for",
        "data-management",
        "data-standards",
        "security",
        "data-protection-and-privacy",
        "data-sharing",
        "ai-and-data-driven-technologies",
        "general-guidance",
      ]
      unless data_manual_content_slugs.include? params[:content_slug]
        render_not_found && return
      end
      render layout: "v2/layouts/data_manual"
    end
  end
end
