require 'csv'

class Preview
  attr_reader :url, :format

  def initialize(url:, format:)
    @url = url
    @format = format
  end

  def render
    csv? ? CSV.parse(fetch_raw) : []
  end

  private

  def fetch_raw
    connection = Faraday.new do |faraday|
      faraday.use FaradayMiddleware::FollowRedirects, limit: 3
      faraday.adapter :net_http
    end

    connection.headers = { 'Range' => 'bytes=0-1024' }

    begin
      response = connection.get do |request|
        request.url(url)
        request.options.timeout = 5
      end
      response.body.rpartition("\n")[0]
    rescue
      ""
    end
  end

  def csv?
    format&.upcase == 'CSV'
  end
end
