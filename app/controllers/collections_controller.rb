class CollectionsController < ApplicationController
  def show
    @collections_service = CollectionsService.new(params[:collection], params[:topic])

    unless @collections_service.valid_collection_topic?
      render_not_found && return
    end

    render collection_topic_path, layout: "version_2/collection", locals: {
      collections: @collections_service.collections_slugs,
      collection: @collections_service.collection,
      side_navigations: @collections_service.side_navigations,
      current_topic: @collections_service.topic,
    }
  end

  def collection_topic_path
    "generated/collections/#{@collections_service.collection}/#{@collections_service.topic}"
  end
end
