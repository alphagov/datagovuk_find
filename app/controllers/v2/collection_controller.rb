require Rails.root.join("app/services/dgu/collections_service")

module V2
  class CollectionController < ApplicationController
    rescue_from Dgu::CollectionNotFound, with: :render_not_found

    def collection_page
      expires_in 30.minutes, public: true
      unless collections_service.valid_collection_page?
        render_not_found && return
      end

      @collection = collections_service.collection
      @collection_pages = collections_service.collection_pages
      @image_path = collections_service.image_path
      @current_page = collections_service.page
      @view_template = collections_service.view_template_path
      @next_page = collections_service.next_page
      @previous_page = collections_service.previous_page
      @title = collections_service.title

      render template: "v2/collection/collection", layout: "v2/layouts/application"
    end

    def collection
      expires_in 30.minutes, public: true
      redirect_to collections_service.priority_page
    end

  private

    def collections_service
      @collections_service ||= Dgu::CollectionsService.new(params[:collection], params[:page])
    end
  end
end
