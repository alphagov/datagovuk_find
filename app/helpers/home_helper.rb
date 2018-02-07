module HomeHelper
  def sanitize(topic_name)
     URI.escape(topic_name)
  end
end
