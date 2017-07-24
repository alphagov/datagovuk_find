require 'rails_helper'

  describe "Datasets" do
    it "displays a dataset" do
      visit "/datasets/1234"
      expect(page).to have_content("Dataset")
    end
  end
