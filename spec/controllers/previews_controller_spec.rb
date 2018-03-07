require 'rails_helper'

describe PreviewsController, type: :controller do
  render_views

  let(:dataset) do
    DatasetBuilder.new
      .with_name('a-nice-dataset')
      .with_datafiles([datafile])
      .build
  end

  let(:datafile) { Datafile.new(CSV_DATAFILE) }

  describe 'Generating the preview of a CSV file' do
    it 'will show the previewed CSV' do
      stub_request(:get, datafile.url).
        to_return(body: "a,Paris,c,d\ne,f,Berlin,h\ni,j,k,l")

      index([dataset])
      get :show, params: { dataset_uuid: dataset[:uuid], name: dataset[:name], datafile_uuid: datafile.uuid }
      expect(response.body).to have_content('Berlin')
    end

    it 'will recover if the datafile server times out' do
      stub_request(:get, datafile.url).
        to_timeout

      index([dataset])
      get :show, params: { dataset_uuid: dataset[:uuid], name: dataset[:name], datafile_uuid: datafile.uuid }

      expect(response.body).to have_content('No preview is available')
    end

    it 'will recover if the datafile server returns an error' do
      stub_request(:get, datafile.url).
        to_return(status: [500, "Internal Server Error"])

      index([dataset])
      get :show, params: { dataset_uuid: dataset[:uuid], name: dataset[:name], datafile_uuid: datafile.uuid }

      expect(response.body).to have_content('No preview is available')
    end

    it 'will recover if the datafile is not CSV' do
      stub_request(:get, datafile.url).
        to_return(body: "<!DOCTYPE html><html lang=\"en\"><h")

      index([dataset])
      get :show, params: { dataset_uuid: dataset[:uuid], name: dataset[:name], datafile_uuid: datafile.uuid }

      expect(response.body).to have_content('No preview is available')
    end

    it 'will recover if the datafile is malformed CSV' do
      stub_request(:get, datafile.url).
        to_return(body: "a,b,\",c,d\n000000\n")

      index([dataset])
      get :show, params: { dataset_uuid: dataset[:uuid], name: dataset[:name], datafile_uuid: datafile.uuid }

      expect(response.body).to have_content('No preview is available')
    end

  end
end
