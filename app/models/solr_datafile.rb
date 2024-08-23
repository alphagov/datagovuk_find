class SolrDatafile
  DatafileNotFound = Class.new(StandardError)

  attr_reader :name, :url, :start_date,
              :created_at, :updated_at, :format, :size, :uuid

  def initialize(hash)
    hash["name"].present? ? @name = hash["name"] : @name = hash["description"]
    @url = hash["url"]
    @start_date = hash["start_date"]
    @created_at = hash["created"]
    # @updated_at = hash["metadata_modified"]
    @format = hash["format"]&.strip&.delete_prefix(".")&.upcase
    # @size = hash["size"]
    @uuid = hash["id"]
  end

  def html?
    format == "HTML"
  end

  def csv?
    format == "CSV"
  end

  def wms?
    format == "WMS"
  end

  def wfs?
    format == "WFS"
  end

  def preview
    @preview ||= Preview.new(url:, format:)
  end
end
