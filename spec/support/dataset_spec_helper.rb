INDEX = "datasets-test"

def index(dataset)
  ELASTIC.index index: INDEX, type: 'dataset', id: 1, body: dataset
  refresh_index
end

def refresh_index
  ELASTIC.indices.refresh index: INDEX
end

def index_and_visit(dataset)
  index(dataset)
  visit "/dataset/#{dataset[:name]}"
end
