module V2
  class ChartsController < ApplicationController
    def download
      base_dir = Rails.root.join(Rails.configuration.x.visualisations_data_location).realpath
      csv_path = base_dir.join(params[:collection], "#{params[:chart]}.csv")

      if csv_path.to_s.start_with?(base_dir.to_s) && File.exist?(csv_path)
        send_file csv_path, type: "text/csv"
      else
        head :not_found
      end
    end
  end
end
