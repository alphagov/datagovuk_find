require "spec_helper"
require "net/http"
require "front_matter_parser"

def extract_link_entries(front_matter)
  entries = []

  Array(front_matter["websites"]).each do |site|
    entries << site if site.is_a?(Hash) && site["url"]
  end

  %w[api dataset].each do |key|
    entry = front_matter[key]
    entries << entry if entry.is_a?(Hash) && entry["url"]
  end

  entries
end

BROWSER_HEADERS = {
  "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36",
  "Accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
  "Accept-Language" => "en-GB,en;q=0.9",
}.freeze

def apply_headers(request)
  BROWSER_HEADERS.each { |k, v| request[k] = v }
  request
end

def check_url(url)
  uri = URI.parse(url)
  response = nil
  redirects = 0

  loop do
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == "https"
    http.open_timeout = 10
    http.read_timeout = 15

    request = apply_headers(Net::HTTP::Head.new(uri.request_uri))
    response = http.request(request)

    # Retry with GET if the server rejects or mishandles HEAD requests
    if [403, 404, 405].include?(response.code.to_i)
      request = apply_headers(Net::HTTP::Get.new(uri.request_uri))
      response = http.request(request)
    end

    break unless response.is_a?(Net::HTTPRedirection) && redirects < 5

    location = response["location"]
    uri = location.start_with?("http") ? URI.parse(location) : URI.join("#{uri.scheme}://#{uri.host}", location)
    redirects += 1
  end

  response
rescue StandardError => e
  e
end

# Sites behind bot detection e.g. Cloudflare seem to reject non-browser HTTP
# clients (TLS fingerprinting, etc.) but work fine in any real browser.
SITES_BLOCKING_AUTOMATED_CLIENTS = %w[
  www.ros.gov.uk
].freeze

RSpec.describe "Collection frontmatter links" do
  collections_path = Pathname.new(File.expand_path("../../app/content/collections", __dir__))

  markdown_files = Dir.glob(collections_path.join("**/*.md")).sort

  markdown_files.each do |file|
    relative_path = Pathname.new(file).relative_path_from(collections_path).to_s
    parsed = FrontMatterParser::Parser.parse_file(file)
    entries = extract_link_entries(parsed.front_matter)

    entries.each do |entry|
      url = entry["url"]

      it "#{relative_path}: #{url} returns HTTP 200" do
        response = check_url(url)

        expect(response).not_to be_a(StandardError),
                                "Request to #{url} failed with error: #{response.message}"
        acceptable = [200, 302]
        acceptable.push(403, 404) if SITES_BLOCKING_AUTOMATED_CLIENTS.include?(URI.parse(url).host)

        expect(acceptable).to include(response.code.to_i),
                              "Expected #{acceptable.join('/')} from #{url}, got #{response.code}"
      end

      it "#{relative_path}: #{url} has non-empty link-text" do
        expect(entry["link-text"]).to be_a(String).and(satisfy("be non-empty") { |s| !s.strip.empty? }),
                                      "Expected non-empty link-text for #{url}"
      end
    end
  end
end
