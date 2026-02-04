class CollectionsController < ApplicationController
  def show
    @collections_service = CollectionsService.new(params[:collection], params[:topic])

    unless @collections_service.collection_topic?(params[:collection], params[:topic]) && FeatureFlag.enabled?(:version_2_collections)
      render_not_found && return
    end

    render collection_topic_path, layout: "version_2/collection", locals: {
      collections: @collections_service.collections_slugs,
      collection: @collections_service.collection_name,
      side_navigations: @collections_service.side_navigations,
      current_topic: @collections_service.topic,
    }
  end

  def collection_topic_path
    "generated/collections/#{@collections_service.collection_name}/#{@collections_service.topic}"
  end
end
