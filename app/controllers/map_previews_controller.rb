require 'addressable'
require 'nokogiri'
require 'open-uri'

class MapPreviewsController < ApplicationController
  def show
    # rubocop:disable Lint/PercentStringArray
    append_content_security_policy_directives(
      img_src: %w(osinspiremappingprod.ordnancesurvey.co.uk data:) << URI(url_param).host,
      script_src: %w(osinspiremappingprod.ordnancesurvey.co.uk 'unsafe-eval'),
      style_src: %w(osinspiremappingprod.ordnancesurvey.co.uk),
    )
    # rubocop:enable Lint/PercentStringArray
  end

  def getinfo
    base_wms_url = url_param.gsub(/;jsessionid=[a-z0-9]+/i, ';jsessionid=')
    response = URI(base_wms_url).read
    render xml: Nokogiri::XML(response)
  rescue StandardError => _e
    render status: :bad_request
  end

  def proxy
    url = correct_url(url_param)
    response = URI(url).read
    render xml: Nokogiri::XML(response)
  rescue StandardError => _e
    render status: :bad_request
  end

private

  def url_param
    params.require(:url)
  end

  def correct_url(url)
    # Some URLs are bad and need cleaning up such as
    # http://lasigpublic.nerc-lancaster.ac.uk/ArcGIS/services/Biodiversity/GMFarmEvaluation/MapServer/WMSServer?request=GetCapabilities&service=WMS

    uri = Addressable::URI.parse(url)
    args = uri.query_values.map { |k, v| [k.downcase, v] }.to_h

    args['request'] ||= 'GetCapabilities'
    args['service'] ||= 'WMS'

    if %w(wms).exclude?(args['service'].downcase)
      raise 'Invalid value for "service"'
    end

    if %w(getcapabilities getfeatureinfo).exclude?(args['request'].downcase)
      raise 'Invalid value for "request"'
    end

    uri.query_values = args
    uri
  end
end
