module V2
  class CollectionController < ApplicationController
    def collection_topic
      unless collections_service.valid_collection_topic?
        render_not_found && return
      end

      @collections = collections_service.collections_slugs
      @collection = collections_service.collection
      @collection_topics = collections_service.collection_topics
      @current_topic = collections_service.topic
      @view_template = collections_service.view_template_path

      render template: "v2/collection/collection", layout: "v2/layouts/application"
    end

    def collection
      unless collections_service.valid_collection_topic?
        render_not_found && return
      end

      redirect_to collection_topic_path(collection: params[:collection], topic: collections_service.priority_topic), status: :found and return
    end

  private

    def collections_service
      @collections_service ||= CollectionsService.new(params[:collection], params[:topic])
    end
  end
end
