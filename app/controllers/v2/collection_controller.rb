module V2
  class CollectionController < ApplicationController
    def show
      unless collections_service.valid_collection_topic?
        render_not_found && return
      end

      @collections = collections_service.collections_slugs
      @collection = collections_service.collection
      @side_navigations = collections_service.side_navigations
      @current_topic = collections_service.topic
      @view_template = collections_service.view_template_path

      render template: "v2/collection/collection", layout: "v2/layouts/application"
    end

  private

    def collections_service
      @collections_service ||= CollectionsService.new(params[:collection], params[:topic])
    end
  end
end
