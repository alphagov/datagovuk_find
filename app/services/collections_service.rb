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

  def collection_topics
    @collection_topics ||= topics.map do |topic_slug|
      {
        url: "/collections/#{@collection}/#{topic_slug}",
        title: topic_slug.gsub("-", " ").capitalize,
        selected: topic_slug == @topic_name,
      }
    end
  end

  def collections_slugs
    Dir.entries(Rails.root.join(COLLECTIONS_LOCATION)).sort
    .reject { |files|
      [".", ".."].include?(files)
    }.map do |collection|
      Struct.new(:slug, :title).new(
        collection,
        collection.gsub("-", " ").humanize,
      )
    end
  end

  def view_template_path
    "generated/collections/#{collection}/#{topic}"
  end

  def first_topic
    @first_topic ||= topics.first
  end

private

  def topics
    Dir.entries(Rails.root.join(COLLECTIONS_LOCATION, @collection)).sort
    .reject { |entry|
      [".", ".."].include?(entry)
    }
    .map do |topic_file_name|
      topic_file_name.gsub(".html.erb", "")
    end
  end

  def topic?(topic = nil)
    return true if topic.blank?

    Rails.root.join(COLLECTIONS_LOCATION, @collection, "#{topic}.html.erb").exist?
  end

  def collection?(collection)
    Rails.root.join(COLLECTIONS_LOCATION, collection).exist?
  end
end
