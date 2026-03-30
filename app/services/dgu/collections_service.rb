module Dgu
  class CollectionsService
    attr_reader :collection, :page_name, :collection_pages

    def initialize(collection, page_name = nil)
      unless collection?(collection)
        raise Dgu::CollectionNotFound, "Collection #{collection} does not exist"
      end

      @collection = collection
      @collection_pages = collection_pages_config[collection].map do |collection_page|
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
      "/v2/collections/badge-#{collection}.png"
    end

    def collections_slugs
      @collections_slugs ||= collection_pages_config.keys.map do |collection_slug|
        Struct.new(:slug, :title).new(collection_slug.to_s, collection_slug.to_s.tr("-", " ").humanize)
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

    def collection_pages_config
      @collection_pages_config ||= YAML.load_file(Rails.root.join("config/collections.yml")).with_indifferent_access
    end

    def pages
      @pages ||= collection_pages_config[@collection].map { |page| page[:slug] }
    end

    def page?(page = nil)
      return true if page.blank?

      pages.include?(page)
    end

    def collection?(collection)
      collections_slugs.map(&:slug).include?(collection)
    end

    def current_page_index
      @collection_pages.index { |page| page[:slug] == @page_name }
    end
  end
end
