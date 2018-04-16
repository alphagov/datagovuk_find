module ApplicationHelper
  def format_timestamp(timestamp)
    Time.parse(timestamp).strftime('%d %B %Y')
  end

  def browser
    Browser.new(request.headers['HTTP_USER_AGENT'])
  end
end
