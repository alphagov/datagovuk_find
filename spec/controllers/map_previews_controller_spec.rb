require "rails_helper"

RSpec.describe MapPreviewsController, type: :controller do
  render_views

  describe "Proxying XML" do
    # it "will show the first six rows (including the header) of the CSV" do
    #   stub_request(:get, datafile.url)
    #     .to_return(body: "...")

    #   index([dataset])
    #   get :show, params: { dataset_uuid: dataset.uuid, name: dataset.name, datafile_uuid: datafile.uuid }

    #   expect(response.body).to have_content("Header row")
    #   expect(response.body).to have_content("2nd row")
    #   expect(response.body).not_to have_content("6th row")
    # end

    it "will respond with 400 Bad Request if encountering StandardError" do
      # url = "/data/preview_proxy?url=https://example.com?service=wms&request=GetCapabilities"
      # stub_request(:get, url).to_timeout

      get :proxy, params: { request: "NOT GetCapabilities", url: "https://example.com" }

      expect(response).to have_http_status(:not_acceptable)
    end

    # it "will recover if the datafile server returns an error" do
    #   stub_request(:get, datafile.url)
    #     .to_return(status: [500, "Internal Server Error"])

    #   index([dataset])
    #   get :show, params: { dataset_uuid: dataset.uuid, name: dataset.name, datafile_uuid: datafile.uuid }

    #   expect(response.body).to have_content(no_preview_notice(datafile))
    #   expect(response.body).not_to have_link("Download this file")
    # end
  end
end
