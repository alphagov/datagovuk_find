SecureHeaders::Configuration.default do |config|
  config.csp = {
    preserve_schemes: true,
    default_src: %w('none'),
    connect_src: %w('self' www.google-analytics.com),
    font_src: %w('self' data:),
    img_src: %w('self' www.google-analytics.com),
    manifest_src: %w('self'),
    media_src: %w('self'),
    object_src: %w('self'),
    script_src: %w('unsafe-inline' 'self' www.google-analytics.com),
    style_src: %w('unsafe-inline' 'self')
  }
end
