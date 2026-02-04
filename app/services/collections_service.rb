class CollectionsService
  attr_reader :collection_name, :topic_name

  COLLECTIONS_LOCATION = Rails.configuration.x.generated_collections_location

  def initialize(collection_name, topic_name = nil)
    @collection_name = collection_name
    @topic_name = topic_name
  end

  def collection_topic?(collection, topic = nil)
    collection?(collection) && topic?(topic)
  end

  def topic
    @topic_name.presence || first_topic
  end

  def first_topic
    @first_topic ||= topics.first.gsub(".html.erb", "")
  end

  def collection?(collection)
    Rails.root.join(COLLECTIONS_LOCATION, collection).exist?
  end

  def topic?(topic)
    return true if topic.blank?

    Rails.root.join(COLLECTIONS_LOCATION, @collection_name, "#{topic}.html.erb").exist?
  end

  def side_navigations
    @side_navigations ||= topics.map do |entry|
      entry.gsub(".html.erb", "")
    end
  end

  def topics
    Dir.entries(Rails.root.join(COLLECTIONS_LOCATION, @collection_name)).sort
    .reject do |entry|
      [".", ".."].include?(entry)
    end
  end

  def collections_slugs
    Dir.entries(Rails.root.join("app/views/generated/collections")).sort
    .reject { |entry|
      [".", ".."].include?(entry)
    }.map do |entry|
      OpenStruct.new(
        slug: entry,
        title: entry.gsub("-", " ").humanize,
      )
    end
  end
end
