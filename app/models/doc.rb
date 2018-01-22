class Doc
  attr_reader :name, :url, :created_at,
              :updated_at, :format, :size,
              :uuid

  def initialize(attrs)
    @name = attrs["name"]
    @url = attrs["url"]
    @created_at = attrs["created_at"]
    @updated_at = attrs["updated_at"]
    @format =  attrs["format"]
    @size =  attrs["size"]
    @uuid = attrs["uuid"]
  end

end
