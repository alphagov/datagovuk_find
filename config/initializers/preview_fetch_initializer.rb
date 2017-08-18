require 'rest-client'
require 'uri'

PUBLISH_URL = ENV['PUBLISH_URL'] || "https://publish-data-beta.herokuapp.com"

def preview_url(file_id)
  URI.join(PUBLISH_URL, "/api/previews/#{file_id}").to_s
end
