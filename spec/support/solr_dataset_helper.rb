def filtered_solr_search_for(sort_method)
  visit "/search/solr"
  within ".dgu-sort" do
    select sort_method, from: "sort-datasets"
  end
  within "#main-content" do
    find(".gem-c-search__submit").click
  end
end
