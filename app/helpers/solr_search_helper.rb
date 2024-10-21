module SolrSearchHelper
  def selected_organisation
    params.dig(:filters, :publisher)
  end
end
