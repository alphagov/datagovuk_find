module V2
  class CollectionController < ApplicationController
    def collection_page
      unless collections_service.valid_collection_page?
        render_not_found && return
      end

      @collection = collections_service.collection
      @collection_pages = collections_service.collection_pages
      @current_page = collections_service.page
      @view_template = collections_service.view_template_path

      render template: "v2/collection/collection", layout: "v2/layouts/application"
    end

    def collection
      unless collections_service.valid_collection_page?
        render_not_found && return
      end

      redirect_to collection_page_path(collection: params[:collection], page: collections_service.priority_page), status: :found and return
    end

  private

    def collections_service
      @collections_service ||= CollectionsService.new(params[:collection], params[:page])
    end
  end
end
