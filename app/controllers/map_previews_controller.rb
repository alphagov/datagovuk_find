require 'addressable'
require 'nokogiri'
require 'open-uri'

class MapPreviewsController < ApplicationController
  def show
    wms_uri = URI(url_param)
    wms_img_src = "#{wms_uri.scheme}://#{wms_uri.host}"

    # rubocop:disable Lint/PercentStringArray
    append_content_security_policy_directives(
      img_src: %W(osinspiremappingprod.ordnancesurvey.co.uk #{wms_img_src} data:),
      script_src: %w(osinspiremappingprod.ordnancesurvey.co.uk 'unsafe-eval'),
      style_src: %w(osinspiremappingprod.ordnancesurvey.co.uk),
    )
    # rubocop:enable Lint/PercentStringArray
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
    response = URI(url).read
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
    # Some URLs are bad and need cleaning up such as
    # http://lasigpublic.nerc-lancaster.ac.uk/ArcGIS/services/Biodiversity/GMFarmEvaluation/MapServer/WMSServer?request=GetCapabilities&service=WMS

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
