module V2
  class DataManualController < ApplicationController
    def home
      expires_in 30.minutes, public: true
      render layout: "v2/layouts/application"
    end
  end
end
