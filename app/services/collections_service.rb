class CollectionsService
  attr_reader :collection, :topic_name

  COLLECTIONS_LOCATION = Rails.configuration.x.generated_collections_location

  def initialize(collection, topic_name = nil)
    @collection = collection
    @topic_name = topic_name
  end

  def valid_collection_topic?
    collection?(collection) && topic?(topic)
  end

  def topic
    @topic_name.presence || first_topic
  end

  def side_navigations
    @side_navigations ||= topics.map do |side_navigation|
      side_navigation.gsub(".html.erb", "")
    end
  end

  def collections_slugs
    Dir.entries(Rails.root.join(COLLECTIONS_LOCATION)).sort
    .reject { |files|
      [".", ".."].include?(files)
    }.map do |collection|
      OpenStruct.new(
        slug: collection,
        title: collection.gsub("-", " ").humanize,
      )
    end
  end

private

  def topics
    Dir.entries(Rails.root.join(COLLECTIONS_LOCATION, @collection)).sort
    .reject do |entry|
      [".", ".."].include?(entry)
    end
  end

  def topic?(topic = nil)
    return true if topic.blank?

    Rails.root.join(COLLECTIONS_LOCATION, @collection, "#{topic}.html.erb").exist?
  end

  def first_topic
    @first_topic ||= topics.first.gsub(".html.erb", "")
  end

  def collection?(collection)
    Rails.root.join(COLLECTIONS_LOCATION, collection).exist?
  end
end
