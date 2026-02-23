module V2
  class CollectionController < ApplicationController
    def show
      unless collections_service.valid_collection_topic?
        render_not_found && return
      end

      @collections = collections_service.collections_slugs
      @data_manuals = []
      @collection = collections_service.collection
      @side_navigations = collections_service.side_navigations
      @current_topic = collections_service.topic
      @view_template = collection_topic_path

      render template: "v2/collection/collection", layout: "v2/layouts/application"
    end

  private

    def collection_topic_path
      "generated/collections/#{collections_service.collection}/#{collections_service.topic}"
    end

    def collections_service
      @collections_service ||= CollectionsService.new(params[:collection], params[:topic])
    end
  end
end
