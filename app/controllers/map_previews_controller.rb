require 'addressable'
require 'nokogiri'
require 'open-uri'

class MapPreviewsController < ApplicationController
  def show
    # rubocop:disable Lint/PercentStringArray
    append_content_security_policy_directives(
      script_src: %w(osinspiremappingprod.ordnancesurvey.co.uk 'unsafe-eval'),
      style_src: %w(osinspiremappingprod.ordnancesurvey.co.uk),
    )
    # rubocop:enable Lint/PercentStringArray

    override_content_security_policy_directives(img_src: %w(* data:))
  end

  def getinfo
    base_wms_url = url_param.gsub(/;jsessionid=[a-z0-9]+/i, ';jsessionid=')
    response = URI(base_wms_url).read
    render xml: Nokogiri::XML(response)
  rescue StandardError => exception
    Raven.capture_exception(exception)
    head :bad_request
  end

  def proxy
    url = correct_url(url_param)
    response = URI(url).read.force_encoding("ISO-8859-1").encode("UTF-8")
    render xml: Nokogiri::XML(response)
  rescue StandardError => exception
    Raven.capture_exception(exception)
    head :bad_request
  end

private

  def url_param
    params.require(:url)
  end

  def correct_url(url)
    uri = Addressable::URI.parse(url)

    args = uri.query_values || {}
    args = args.transform_keys(&:downcase)

    args['request'] ||= params.fetch('request', 'GetCapabilities')
    args['service'] = 'WMS'

    if %w(getcapabilities getfeatureinfo).exclude?(args['request'].downcase)
      raise "Invalid request value for #{uri}"
    end

    uri.query_values = args
    uri
  end
end
