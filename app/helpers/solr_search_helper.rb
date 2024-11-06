module SolrSearchHelper
  def selected_format
    params.dig(:filters, :format)
  end
end
