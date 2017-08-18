module SearchHelper

  def display_sort(sort)
    sort == 'best' ? "Best Match" : "Most Recent"
  end

  def format(timestamp)
    Time.parse(timestamp).strftime("%d %B %Y")
  end
end
