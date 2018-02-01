INDEX = "datasets-test"

def index(datasets)
  datasets.each do |dataset, i|
    ELASTIC.index index: INDEX, type: 'dataset', id: i, body: dataset
  end
  refresh_index
end

def refresh_index
  ELASTIC.indices.refresh index: INDEX
end

def index_and_visit(dataset)
  index([dataset])
  visit dataset_path(dataset[:short_id], dataset[:name])
end

def search_for(query)
  visit '/'
  within '#content' do
    fill_in 'q', with: query
    find('.dgu-search-box__button').click
  end
end

def filtered_search_for(query, sort_method)
  visit '/search'
  within '#content' do
    fill_in 'q', with: query
    select sort_method, from: 'Sorting type'
    find('.dgu-search-box__button').click
  end
end
