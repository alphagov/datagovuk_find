module Dgu
  class CollectionsService
    COLLECTIONS_LOCATION = Rails.configuration.x.generated_collections_location
    COLLECTION_PAGES = Rails.configuration.x.collection_pages.deep_dup

    attr_reader :collection, :page_name, :collection_pages

    def initialize(collection, page_name = nil)
      unless collection?(collection)
        raise Dgu::CollectionNotFound
      end

      @collection = collection
      @collection_pages = COLLECTION_PAGES[collection].map do |collection_page|
        {
          url: "/collections/#{@collection}/#{collection_page[:slug]}",
          slug: collection_page[:slug],
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

    def image_path
      "/images/collections/#{collection}.jpg"
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
      @priority_page ||= @collection_pages[0][:url]
    end

    def next_page
      return if current_page_index == @collection_pages.length - 1

      @next_page ||= @collection_pages[current_page_index + 1]
    end

    def previous_page
      return if current_page_index <= 0

      @previous_page ||= @collection_pages[current_page_index - 1]
    end

    def title
      @collection_pages[current_page_index][:title]
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

    def current_page_index
      @collection_pages.index { |page| page[:slug] == @page_name }
    end
  end
end
