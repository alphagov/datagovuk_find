SecureHeaders::Configuration.default do |config|
  config.csp = {
    preserve_schemes: true,
    default_src: ["'none'"],
    connect_src: ["'self'", "*.google-analytics.com", "*.googletagmanager.com", "*.analytics.google.com"],
    font_src: ["'self'", "data:"],
    img_src: ["'self'", "*.google-analytics.com", "*.googletagmanager.com"],
    manifest_src: ["'self'"],
    media_src: ["'self'"],
    object_src: ["'self'"],
    script_src: ["'unsafe-inline'", "'self'", "*.google-analytics.com", "*.googletagmanager.com"],
    style_src: ["'unsafe-inline'", "'self'"],
  }
end
