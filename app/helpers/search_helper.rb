module SearchHelper
  def best?
    @sorted_by == 'best'
  end

  def no_sort?
    @sorted_by.nil? || @sorted_by.empty?
  end

  def recent?
    @sorted_by == 'recent'
  end

  def viewed?
    @sorted_by == 'viewed'
  end

  def central?
    @org_type == "central"
  end

  def local?
    @org_type == "local"
  end

  def bodies?
    @org_type == "bodies"
  end

  def format(timestamp)
    Time.parse(timestamp).strftime("%d %B %Y")
  end
end
