module ApplicationHelper
  def format_timestamp(timestamp)
    Time.parse(timestamp).strftime('%d %B %Y')
  end
end
