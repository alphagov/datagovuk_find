module V2
  class PagesController < ApplicationController
    def home
      expires_in 30.minutes, public: true
      render layout: "v2/layouts/application"
    end

    def components
      @average_house_prices = JSON.parse(File.read(Rails.root.join("app/data/average_house_prices/regional_prices.json")))
      render layout: "v2/layouts/application"
    end
  end
end
