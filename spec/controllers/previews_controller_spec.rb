require 'rails_helper'

RSpec.describe PreviewsController, type: :controller do
  render_views

  let(:dataset) { build :dataset, :with_datafile }
  let(:datafile) { dataset.datafiles.first }

  describe 'Generating the preview of a CSV file' do
    it 'will show the first six rows (including the header) of the CSV' do
      stub_request(:get, datafile.url).
        to_return(body: "Header row,Name,Grade,Job Title,Job/Team Function,Parent Department,Organisation,Unit,Contact Phone,Contact Email,Reports to Senior Post,Salary,FTE,Actual Pay Floor,Actual Pay Ceiling,Professional,Notes,Valid? \n2nd row,Romeo Juliet SCSX,Permanent Director,Lorem ipsum dolor sit amet consectetur adipiscing elit. Mauris tincidunt in odio sed dignissim. Vivamus quis auctor mi. Praesent et pharetra tellus. Donec eget dapibus purus cursus hendrerit massa. Phasellus ac velit lobortis sem volutpat euismod. Duis aliquam urna ac pulvinar cursus. Aliquam iaculis sit amet diam a commodo.,Cabinet Office,Cabinet Office,Cabinet Office,012 3456 7890,email@test.com,317,xx,1,123000,345000,x,profession,non,1,romeo,sierra \n3rd row,Romeo Juliet SCSX,Permanent Director,Lorem ipsum dolor sit amet consectetur adipiscing elit. Mauris tincidunt in odio sed dignissim. Vivamus quis auctor mi. Praesent et pharetra tellus. Donec eget dapibus purus cursus hendrerit massa. Phasellus ac velit lobortis sem volutpat euismod. Duis aliquam urna ac pulvinar cursus. Aliquam iaculis sit amet diam a commodo.,Cabinet Office,Cabinet Office,Cabinet Office,012 3456 7890,email@test.com,317,xx,1,123000,345000,x,profession,non,1,romeo,sierra \n4th row,Romeo Juliet SCSX,Permanent Director,Lorem ipsum dolor sit amet consectetur adipiscing elit. Mauris tincidunt in odio sed dignissim. Vivamus quis auctor mi. Praesent et pharetra tellus. Donec eget dapibus purus cursus hendrerit massa. Phasellus ac velit lobortis sem volutpat euismod. Duis aliquam urna ac pulvinar cursus. Aliquam iaculis sit amet diam a commodo.,Cabinet Office,Cabinet Office,Cabinet Office,012 3456 7890,email@test.com,317,xx,1,123000,345000,x,profession,non,1,romeo,sierra \n5th row,Romeo Juliet SCSX,Permanent Director,Lorem ipsum dolor sit amet consectetur adipiscing elit. Mauris tincidunt in odio sed dignissim. Vivamus quis auctor mi. Praesent et pharetra tellus. Donec eget dapibus purus cursus hendrerit massa. Phasellus ac velit lobortis sem volutpat euismod. Duis aliquam urna ac pulvinar cursus. Aliquam iaculis sit amet diam a commodo.,Cabinet Office,Cabinet Office,Cabinet Office,012 3456 7890,email@test.com,317,xx,1,123000,345000,x,profession,non,1,romeo,sierra \n6th row,Romeo Juliet SCSX,Permanent Director,Lorem ipsum dolor sit amet consectetur adipiscing elit. Mauris tincidunt in odio sed dignissim. Vivamus quis auctor mi. Praesent et pharetra tellus. Donec eget dapibus purus cursus hendrerit massa. Phasellus ac velit lobortis sem volutpat euismod. Duis aliquam urna ac pulvinar cursus. Aliquam iaculis sit amet diam a commodo.,Cabinet Office,Cabinet Office,Cabinet Office,012 3456 7890,email@test.com,317,xx,1,123000,345000,x,profession,non,1,romeo,sierra\n")

      index([dataset])
      get :show, params: { dataset_uuid: dataset.uuid, name: dataset.name, datafile_uuid: datafile.uuid }

      expect(response.body).to have_content('Header row')
      expect(response.body).to have_content('2nd row')
      expect(response.body).not_to have_content("6th row")
    end

    it 'will recover if the datafile server times out' do
      stub_request(:get, datafile.url).
        to_timeout

      index([dataset])
      get :show, params: { dataset_uuid: dataset.uuid, name: dataset.name, datafile_uuid: datafile.uuid }

      expect(response.body).to have_content(no_preview_notice(datafile))
      expect(response.body).not_to have_link("Download this file")
    end

    it 'will recover if the datafile server returns an error' do
      stub_request(:get, datafile.url).
        to_return(status: [500, "Internal Server Error"])

      index([dataset])
      get :show, params: { dataset_uuid: dataset.uuid, name: dataset.name, datafile_uuid: datafile.uuid }

      expect(response.body).to have_content(no_preview_notice(datafile))
      expect(response.body).not_to have_link("Download this file")
    end

    it 'will recover if the datafile is not CSV' do
      stub_request(:get, datafile.url).
        to_return(body: "<!DOCTYPE html><html lang=\"en\"><h")

      index([dataset])
      get :show, params: { dataset_uuid: dataset.uuid, name: dataset.name, datafile_uuid: datafile.uuid }

      expect(response.body).to have_content(no_preview_notice(datafile))
      expect(response.body).not_to have_link("Download this file")
    end

    it 'will recover if the datafile is malformed CSV' do
      stub_request(:get, datafile.url).
        to_return(body: "a,b,\",c,d\n000000\n")

      index([dataset])
      get :show, params: { dataset_uuid: dataset.uuid, name: dataset.name, datafile_uuid: datafile.uuid }

      expect(response.body).to have_content(no_preview_notice(datafile))
      expect(response.body).not_to have_link("Download this file")
    end

    def no_preview_notice(datafile)
      "Currently there is no preview available for \"#{datafile.name}\""
    end
  end
end
