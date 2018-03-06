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

  describe 'dataset page' do
    it 'redirects to the latest slugged URL' do
      legacy_name = 'a-legacy-name'
      dataset = DatasetBuilder.new.with_legacy_name(legacy_name).build
      index([dataset])

      get "/dataset/#{legacy_name}"

      expect(response).to redirect_to(dataset_url(dataset[:short_id], dataset[:name]))
      expect(response).to have_http_status(:moved_permanently)
    end
  end

  describe 'datafile resources' do
    let(:legacy_dataset_name) { 'a-legacy-name' }
    let(:datafile) { CSV_DATAFILE.with_indifferent_access }
    let(:dataset) do
      DatasetBuilder
        .new
        .with_legacy_name(legacy_dataset_name)
        .with_datafiles([datafile])
        .build
    end

    context 'when the datafile can not be found' do
      it 'returns a not found error page' do
        get "/dataset/#{legacy_dataset_name}/resource/#{datafile[:uuid]}"

        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when the datafile exists' do
      before { index([dataset]) }

      it 'redirects to the datefile preview page' do
        get "/dataset/#{legacy_dataset_name}/resource/#{datafile[:uuid]}"

        location = datafile_preview_path(
          dataset[:short_id], dataset[:name], datafile[:short_id]
        )

        expect(response).to redirect_to(location)
        expect(response).to have_http_status(:moved_permanently)
      end
    end
  end

  describe 'contact page' do
    it 'redirects to the support page' do
      get '/contact'

      expect(response).to redirect_to(support_url)
      expect(response).to have_http_status(:moved_permanently)
    end
  end

  describe 'cookies page' do
    it 'redirects to the cookies page' do
      get '/cookies-policy'

      expect(response).to redirect_to(cookies_url)
      expect(response).to have_http_status(:moved_permanently)
    end
  end

  describe 'accessibility page' do
    it 'redirects to the accessibility page' do
      get '/accessibility-statement'

      expect(response).to redirect_to(accessibility_url)
      expect(response).to have_http_status(:moved_permanently)
    end
  end

  describe 'technical details page' do
    it 'redirects to the about page' do
      get '/technical-details'

      expect(response).to redirect_to(about_url)
      expect(response).to have_http_status(:moved_permanently)
    end
  end

  describe 'terms and conditions page' do
    it 'redirects to the terms page' do
      get '/terms-and-conditions'

      expect(response).to redirect_to(terms_url)
      expect(response).to have_http_status(:moved_permanently)
    end
  end

  describe 'faqs page' do
    it 'redirects to the about page' do
      get '/faq'

      expect(response).to redirect_to(about_url)
      expect(response).to have_http_status(:moved_permanently)
    end
  end

  describe 'apps page' do
    it 'redirects to site changes page' do
      get '/apps'

      expect(response).to redirect_to(site_changes_url)
      expect(response).to have_http_status(:moved_permanently)
    end
  end

  describe 'individual app pages' do
    it 'redirect to site changes page' do
      get '/apps/foobar'

      expect(response).to redirect_to(site_changes_url)
      expect(response).to have_http_status(:moved_permanently)
    end
  end

  describe 'node pages' do
    it 'redirect to site changes page' do
      get '/node/foobar'

      expect(response).to redirect_to(site_changes_url)
      expect(response).to have_http_status(:moved_permanently)
    end
  end

  describe 'reply pages' do
    it 'redirect to site changes page' do
      get '/reply/foobar'

      expect(response).to redirect_to(site_changes_url)
      expect(response).to have_http_status(:moved_permanently)
    end
  end

  describe 'comments pages' do
    it 'redirect to site changes page' do
      get '/comments/foobar'

      expect(response).to redirect_to(site_changes_url)
      expect(response).to have_http_status(:moved_permanently)
    end
  end

  describe 'forum pages' do
    it 'redirect to site changes page' do
      get '/forum/foobar'

      expect(response).to redirect_to(site_changes_url)
      expect(response).to have_http_status(:moved_permanently)
    end
  end

  describe 'issues pages' do
    it 'redirect to site changes page' do
      get '/dataset/issues/bar'

      expect(response).to redirect_to(site_changes_url)
      expect(response).to have_http_status(:moved_permanently)
    end
  end
end
