def filtered_solr_search_for(sort_method)
  visit "/search/solr"
  within "#main-content" do
    select sort_method, from: "Sort by"
    find(".gem-c-search__submit").click
  end
end
