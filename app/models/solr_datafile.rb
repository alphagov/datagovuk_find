class SolrDatafile
  attr_reader :name, :url, :created_at,
              :format, :size, :uuid

  def initialize(hash)
    @name = hash["name"] || hash["description"]
    @url = hash["url"]
    @created_at = hash["created"]
    @format = hash["format"]&.strip&.delete_prefix(".")&.upcase
    @size = hash["size"]
    @uuid = hash["id"]
  end
end
