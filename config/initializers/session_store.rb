Rails.application.config.session_store :cookie_store, expire_after: 14.days, secure: !(Rails.env.development? || Rails.env.test?), httponly: true
