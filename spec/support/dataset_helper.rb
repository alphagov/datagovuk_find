def search_for(query)
  visit "/"
  within "#main-content" do
    fill_in "q", with: query
    find(".gem-c-search__submit").click
  end
end

def filtered_search_for(query, sort_method)
  visit search_os_path
  within "#main-content" do
    fill_in "q", with: query
    select sort_method, from: "Sort by"
    find(".gem-c-search__submit").click
  end
end
