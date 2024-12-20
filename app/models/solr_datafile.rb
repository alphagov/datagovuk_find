class SolrDatafile
  attr_reader :name, :url, :created_at,
              :format, :uuid

  def initialize(hash, created_at)
    @name = hash["name"] || hash["description"]
    @url = hash["url"]

    @created_at = hash["created"] || created_at
    @format = hash["format"]&.strip&.delete_prefix(".")&.delete_suffix(".")&.upcase
    @uuid = hash["id"]
  end

  def csv?
    format == "CSV"
  end

  def preview
    @preview ||= Preview.new(url:, format:)
  end

  class NotFound < StandardError; end
end
