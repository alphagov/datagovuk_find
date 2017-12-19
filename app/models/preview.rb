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
    connection = build_connection

    connection.headers = { 'Range' => 'bytes=0-1024' }

    begin
      response = connection.get do |request|
        request.url(url)
        request.options.timeout = 5
      end
      # some datafiles have a format type of CSV but are HTML links.
      unless html?(response)
        raw_body = response.body.tr("\r", "\n").force_encoding('iso-8859-1').encode('utf-8')
        raw_body.rpartition("\n")[0]
      end
    rescue
      ""
    end
  end

  def build_connection
    Faraday.new do |faraday|
      faraday.use FaradayMiddleware::FollowRedirects, limit: 3
      faraday.adapter :net_http
    end
  end

  def html?(response)
    response.body[1..100].include? "DOCTYPE"
  end

  def csv?
    format&.upcase == 'CSV'
  end
end
