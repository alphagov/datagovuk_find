module V2
  class PagesController < ApplicationController
    def home
      expires_in 30.minutes, public: true
      render layout: "v2/layouts/application"
    end

    def components
      @data = JSON.parse(File.read(Rails.root.join("app/data/regional_prices.json")))
      render layout: "v2/layouts/application"
    end
  end
end
