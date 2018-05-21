class Doc
  attr_reader :name, :url, :format, :uuid, :created_at

  def initialize(hash)
    @name = hash["name"]
    @url = hash["url"]
    @format = hash["format"]
    @created_at = hash["created_at"]
    @uuid = hash["uuid"]
  end
end
