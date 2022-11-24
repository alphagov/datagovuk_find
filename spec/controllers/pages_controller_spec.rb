require "rails_helper"

RSpec.describe PagesController, type: :controller do
  render_views

  describe "Homepage" do
    it "caches for 30 minutes" do
      get :home

      expect(response.headers["Cache-Control"]).to eq("max-age=1800, public")
    end
  end
end
