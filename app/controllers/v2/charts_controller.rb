module V2
  class ChartsController < ApplicationController
    ALLOWED_EXTENSIONS = %w[.csv .xlsx .xls].freeze
    BASE_DIR = Rails.root.join(Rails.configuration.x.visualisations_data_location).realpath

    def download
      if chart_files.any?
        file_path = chart_files.first
        file_extension = File.extname(file_path).delete(".")
        send_file file_path, type: Mime::Type.lookup_by_extension(file_extension), disposition: "attachment"
      else
        render_not_found
      end
    end

  private

    def safe_topic
      File.basename(params[:topic])
    end

    def safe_chart
      File.basename(params[:chart])
    end

    def chart_files
      pattern = BASE_DIR.join(safe_topic, "#{safe_chart}.*").to_s

      Dir.glob(pattern).select do |path|
        ALLOWED_EXTENSIONS.include?(File.extname(path).downcase)
      end
    end
  end
end
