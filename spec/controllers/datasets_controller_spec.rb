require 'rails_helper'


describe DatasetsController, type: :controller do
  render_views

  describe 'Breadcrumb' do
    context 'Visiting search results from within the application' do
      it 'will not display the publisher name if the referrer host name is the application host name' do
        request.env['HTTP_REFERER'] = 'http://test.host/search?q=fancypants'

        create_dataset_and_visit

        expect(response.body).to have_css('div.datagov_breadcrumb')
        expect(response.body).to_not have_css('li', text: 'Ministry of Defence')
        expect(response.body).to have_css('li', text: 'Search')
      end
    end

    context 'Visiting search results from outside the application' do
      it 'will display the publisher name if the user has visited the search page from outside the application' do
        request.env['HTTP_REFERER'] = 'http://unknown.host/search?q=fancypants'

        create_dataset_and_visit

        expect(response.body).to have_css('div.datagov_breadcrumb')
        expect(response.body).to have_css('li', text: 'Ministry of Defence')
        expect(response.body).to_not have_css('li', text: 'Search')
      end
    end
  end

  describe 'Preview' do
    context 'Generating the preview of a CSV file' do
      it 'will show the previewed CSV' do
        stub_request(:any, FETCH_PREVIEW_URL).
          to_return(body: "a,Paris,c,d\ne,f,Berlin,h\ni,j,k,l")

        create_dataset_and_visit

        get :preview, params: { name: 'a-nice-dataset', uuid: SAMPLE_UUID }
        expect(response.body).to have_content('Berlin')
      end

      it 'will recover if the datafile server times out' do
        stub_request(:any, FETCH_PREVIEW_URL).
          to_timeout

        create_dataset_and_visit

        get :preview, params: { name: 'a-nice-dataset', uuid: SAMPLE_UUID }
        expect(response.body).to have_content('No preview is available')
      end

      it 'will recover if the datafile server returns an error' do
        stub_request(:any, FETCH_PREVIEW_URL).
          to_return(status: [500, "Internal Server Error"])

        create_dataset_and_visit

        get :preview, params: { name: 'a-nice-dataset', uuid: SAMPLE_UUID }
        expect(response.body).to have_content('No preview is available')
      end
    end
  end
end

def create_dataset_and_visit
  slug = 'a-nice-dataset'

  dataset = DatasetBuilder.new
                .with_name(slug)
                .with_title('A nice dataset')
                .with_datafiles([Datafile.new(CSV_DATAFILE)])
                .build

  index([dataset])
  get :show, params: {name: slug}
end
