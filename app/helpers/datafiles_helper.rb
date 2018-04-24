module DatafilesHelper
  def group_and_order(datafiles)
    datafiles.group_by(&:start_year).sort.reverse
  end

  def sort_by_created_at(datafiles)
    datafiles.sort_by(&:created_at).reverse
  end

  def format_of(datafile)
    (datafile.format.presence || 'n/a').upcase
  end

  def show_more?(index)
    "js-show-more-datafiles" unless (0...5).cover? index
  end
end
