module SolrSearchHelper
  def solr_dataset_publishers_for_select(organisations)
    Search::Solr.get_organisations
  end
end
