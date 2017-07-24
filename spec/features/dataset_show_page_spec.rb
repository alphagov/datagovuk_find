require 'rails_helper'

  describe "Datasets" do
    it "displays a dataset" do
      visit "/dataset/1234"
      expect(page).to have_content("Published by")
    end
  end
