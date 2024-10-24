module SolrSearchHelper
  def selected_publisher
    params.dig(:filters, :publisher)
  end
end
