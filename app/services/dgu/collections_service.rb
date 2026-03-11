module Dgu
  class CollectionNotFound < LoadError
  end

  class CollectionsService
    COLLECTIONS_LOCATION = Rails.configuration.x.generated_collections_location
    COLLECTION_PAGES = Rails.configuration.x.collection_pages

    def initialize(collection, page_name = nil)
      unless collection?(collection)
        raise CollectionNotFound
      end

      @collection = collection
      @collection_pages = COLLECTION_PAGES[collection].deep_dup.map do |collection_page|
        {
          url: "/collections/#{@collection}/#{collection_page[:slug]}",
          title: collection_page[:title],
          selected: collection_page[:slug] == page_name,
        }
      end
      @page_name = page_name
    end

    def valid_collection_page?
      collection?(collection) && page?(page)
    end

    def page
      @page_name.presence
    end

    attr_reader :collection, :page_name, :collection_pages

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
      @priority_page ||= @collection_pages[0][:url]
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
end
