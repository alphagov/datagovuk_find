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
    begin
      csv? ? CSV.parse(fetch_raw).reject(&:empty?) : []
    rescue StandardError
      []
    end
  end

  def fetch_raw
    connection = build_connection

    connection.headers = { 'Range' => 'bytes=0-4096' }

    begin
      response = connection.get do |request|
        request.url(url)
        request.options.timeout = 5
      end
      raw_body = response.body.tr("\r", "\n").force_encoding('iso-8859-1').encode('utf-8')
      raw_body.rpartition("\n")[0]
    rescue StandardError
      ""
    end
  end

  def build_connection
    Faraday.new do |faraday|
      faraday.use FaradayMiddleware::FollowRedirects, limit: 3
      faraday.adapter :net_http
    end
  end

  def csv?
    format&.upcase == 'CSV'
  end
end
