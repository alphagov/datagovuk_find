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

  describe 'visiting a dataset page with a legacy URL' do
    it "redirects to the latest slugged URL" do
      legacy_name = 'a-legacy-name'
      dataset = DatasetBuilder.new.with_legacy_name(legacy_name).build
      index([dataset])

      get "/dataset/#{legacy_name}"

      expect(response).to redirect_to(dataset_url(dataset[:uuid], dataset[:name]))
      expect(response.status).to eql 301
    end
  end
end
