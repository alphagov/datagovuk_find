SecureHeaders::Configuration.default do |config|
  config.cookies = {
    secure: true,
    httponly: true,
    samesite: {
      lax: true
    }
  }
  config.hsts = "max-age=#{1.week.to_i}"
  config.x_frame_options = "DENY"
  config.x_content_type_options = "nosniff"
  config.x_xss_protection = "1; mode=block"
  config.x_download_options = "noopen"
  config.x_permitted_cross_domain_policies = "none"
  config.referrer_policy = %w(origin-when-cross-origin strict-origin-when-cross-origin)
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