Kaminari.configure do |config|
  config.default_per_page = 20
end

Kaminari::Hooks.init if defined?(Kaminari::Hooks)
Elasticsearch::Model::Response::Response.__send__ :include, Elasticsearch::Model::Response::Pagination::Kaminari
