require 'csv'

class Preview
  attr_reader :url, :format, :body

  def initialize(url:, format:)
    @url = url
    @format = format
    @body = render
  end

  def line_count
    rows.length
  end

  def headers
    body.first
  end

  def rows
    body.drop(1).take(4)
  end

  def exists?
    body.present?
  end

  private

  def render
    csv? ? CSV.parse(fetch_raw).reject{ |l| l.empty? } : []
  end

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

      raw_body = response.body.gsub("\r", "\n")
      raw_body.rpartition("\n")[0]

    rescue
      ""
    end
  end

  def fetch_headers
    connection = Faraday.new do |faraday|
      faraday.use FaradayMiddleware::FollowRedirects, limit: 3
      faraday.adapter :net_http
    end

    begin
      response = connection.head do |request|
        request.url(url)
        request.options.timeout = 5
      end

      response.headers

    rescue
      {}
    end
  end

  def csv?
    format&.upcase == 'CSV'
  end
end
