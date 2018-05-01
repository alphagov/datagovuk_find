SecureHeaders::Configuration.default do |config|
  config.csp = {
    preserve_schemes: true,
    default_src: ["'none'"],
    connect_src: ["'self'", "www.google-analytics.com"],
    font_src: ["'self'", "data:"],
    img_src: ["'self'", "www.google-analytics.com"],
    manifest_src: ["'self'"],
    media_src: ["'self'"],
    object_src: ["'self'"],
    script_src: ["'unsafe-inline'", "'self'", "www.google-analytics.com"],
    style_src: ["'unsafe-inline'", "'self'"]
  }
end
