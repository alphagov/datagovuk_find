Kaminari.configure do |config|
  config.default_per_page = 20
end

Kaminari::Hooks.init if defined?(Kaminari::Hooks)
Elasticsearch::Model::Response::Response.include Elasticsearch::Model::Response::Pagination::Kaminari

# This is a workaround suggested by the Kaminari team to fix a security issue:
#  https://github.com/kaminari/kaminari/security/advisories/GHSA-r5jw-62xg-j433
#
# Ideally we would upgrade to Kaminari 1.2, but we can't because:
#  https://github.com/elastic/elasticsearch-rails/issues/966
module Kaminari::Helpers
  PARAM_KEY_EXCEPT_LIST = %i[authenticity_token commit utf8 _method script_name original_script_name].freeze
end
