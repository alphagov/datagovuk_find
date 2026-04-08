module Dgu
  class CollectionNotFound < LoadError
  end

  class CollectionsService
    attr_reader :collection, :page_name, :collection_pages

    def initialize(collection, page_name = nil)
      unless collection?(collection)
        raise CollectionNotFound
      end

      @collection = collection
      @collection_pages = collections_config[collection].map do |collection_page|
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

    def collections_config
      Rails.configuration.x.collection_pages
    end

    def collections_slugs
      Dir.children(Rails.root.join(collections_location)).sort
      .map do |collection|
        Struct.new(:slug, :title).new(
          collection,
          collection.gsub("-", " ").humanize,
        )
      end
    end

    def pages
      Dir.entries(Rails.root.join(collections_location, @collection)).sort
      .reject { |entry|
        [".", ".."].include?(entry)
      }
      .map do |page_file_name|
        page_file_name.gsub(".html.erb", "")
      end
    end

    def page?(page = nil)
      return true if page.blank?

      Rails.root.join(collections_location, @collection, "#{page}.html.erb").exist?
    end

    def collection?(collection)
      Rails.root.join(collections_location, collection).exist?
    end

    def current_page_index
      @collection_pages.index { |page| page[:slug] == @page_name }
    end

    def collections_location
      Rails.configuration.x.generated_collections_location
    end
  end
end
