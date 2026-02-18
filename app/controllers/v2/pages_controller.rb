module V2
  class PagesController < ApplicationController
    def home
      expires_in 30.minutes, public: true
      @collections = []
      render layout: "v2/layouts/application"
    end

    def components
      @collections = []
      render layout: "v2/layouts/application"
    end
  end
end
