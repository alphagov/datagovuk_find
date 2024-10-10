class SolrDatafile
  attr_reader :name, :url, :created_at,
              :format, :size, :uuid

  def initialize(hash, created_at)
    @name = hash["name"] || hash["description"]
    @url = hash["url"]

    @created_at = hash["created"] || created_at
    @format = hash["format"]&.strip&.delete_prefix(".")&.upcase
    @size = hash["size"]
    @uuid = hash["id"]
  end
end
