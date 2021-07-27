module PreviewsHelper
  def download_text(dataset, datafile)
    if datafile.csv? && dataset.organogram?
      "Download the CSV"
    else
      t(".download_file")
    end
  end

  def numeric?(value)
    value.to_s.match?(/\A
                      -? # may be negative
                      (
                        \d+(\.\d+)? # digits, potential followed by decimal
                        |
                        \.\d+ # decimal point followed by digits
                      )
                      \Z/x)
  end
end
