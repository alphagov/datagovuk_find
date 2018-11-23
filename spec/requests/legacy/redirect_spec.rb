require 'rails_helper'

RSpec.describe 'legacy', type: :request do
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

  describe 'dataset page' do
    let(:dataset) { build :dataset, legacy_name: 'a-legacy-name' }

    before do
      index(dataset)
    end

    it 'redirects to the latest slugged URL' do
      get "/dataset/#{dataset.legacy_name}"
      expect(response).to redirect_to(dataset_url(dataset.uuid, dataset.name))
      expect(response).to have_http_status(:moved_permanently)
    end
  end

  describe 'datafile resources' do
    let(:dataset) { build :dataset, :with_datafile, legacy_name: 'legacy' }

    context 'when the datafile can not be found' do
      it 'returns a not found error page' do
        get "/dataset/legacy/resource/#{dataset.datafiles.first.uuid}"
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when the datafile exists' do
      before do
        index(dataset)
      end

      it 'redirects to the datefile preview page' do
        get "/dataset/legacy/resource/#{dataset.datafiles.first.uuid}"

        location = datafile_preview_path(dataset.uuid, dataset.name,
                                         dataset.datafiles.first.uuid)

        expect(response).to redirect_to(location)
        expect(response).to have_http_status(:moved_permanently)
      end
    end
  end
end

RSpec.describe 'CKANRouter' do
  describe 'routing' do
    it 'routes GET /publish to CKAN domain' do
      get "/publish"
      location = "http://testdomain/publish"

      expect(response).to redirect_to(location)
    end
  end
end
