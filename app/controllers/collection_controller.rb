class CollectionController < ApplicationController
  def show
    unless collections_service.valid_collection_topic?
      render_not_found && return
    end

    @collections = collections_service.collections_slugs
    @collection = collections_service.collection
    @side_navigations = collections_service.side_navigations
    @current_topic = collections_service.topic
    @view_template = collection_topic_path

    render template: "version_2/collection", layout: "version_2/application"
  end

private

  def collection_topic_path
    "generated/collections/#{collections_service.collection}/#{collections_service.topic}"
  end

  def collections_service
    @collections_service ||= CollectionsService.new(params[:collection], params[:topic])
  end
end
