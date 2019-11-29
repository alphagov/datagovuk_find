module ApplicationHelper
  def format_timestamp(timestamp)
    Time.zone.parse(timestamp).strftime("%d %B %Y")
  end
end
