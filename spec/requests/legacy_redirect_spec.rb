require 'rails_helper'

describe 'legacy', :type => :request do
  describe 'search query' do
    it 'is redirected to search results page with original query and filters' do
      legacy_params = {
        "q" => 'foo',
        "res_format" => 'bar',
        "publisher" => 'baz',
        "license_id-is-ogl" => "true"
      }

      get "/data/search?#{legacy_params.to_query}"

      expected_params = {
        "q" => 'foo',
        "filters" => {
          "format" => 'bar',
          "publisher" => 'baz',
          "licence" => 'uk-ogl'
        }
      }

      expect(response).to redirect_to(search_path(expected_params))
    end
  end
end
