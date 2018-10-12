module PreviewsHelper
  def download_text(dataset, datafile)
    if datafile.csv? && dataset.organogram?
      "Download the CSV"
    else
      t('.download_file')
    end
  end
end
