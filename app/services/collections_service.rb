class CollectionsService
  attr_reader :collection, :page_name

  COLLECTIONS_LOCATION = Rails.configuration.x.generated_collections_location

  def initialize(collection, page_name = nil)
    @collection = collection
    @page_name = page_name
  end

  def valid_collection_page?
    collection?(collection) && page?(page)
  end

  def page
    @page_name.presence || priority_page
  end

  def collection_pages
    @collection_pages ||= pages.map do |page_slug|
      {
        url: "/collections/#{@collection}/#{page_slug}",
        title: page_slug.gsub("-", " ").capitalize,
        selected: page_slug == @page_name,
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
    "generated/collections/#{collection}/#{page}"
  end

  def priority_page
    priority_pages = {
      "business-and-economy": "agricultural-commodity-prices",
      "government": "election-results-data",
      "land-and-property": "dwelling-stock",
      "people": "deprivation",
      "transport": "driving-tests",
    }.with_indifferent_access
    @priority_page ||= priority_pages.fetch(@collection, pages.first)
  end

private

  def pages
    Dir.entries(Rails.root.join(COLLECTIONS_LOCATION, @collection)).sort
    .reject { |entry|
      [".", ".."].include?(entry)
    }
    .map do |page_file_name|
      page_file_name.gsub(".html.erb", "")
    end
  end

  def page?(page = nil)
    return true if page.blank?

    Rails.root.join(COLLECTIONS_LOCATION, @collection, "#{page}.html.erb").exist?
  end

  def collection?(collection)
    Rails.root.join(COLLECTIONS_LOCATION, collection).exist?
  end
end
