class SolrDataset
  include ActiveModel::Model

  DatasetNotFound = Class.new(StandardError)

  attr_reader :title

  def initialize(dataset)
    @title = dataset["title"]
  end
end
