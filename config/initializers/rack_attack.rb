class Rack::Attack
  Rack::Attack.enabled = !Rails.env.test?
  RATE_LIMIT_COUNT = (ENV.fetch("RATE_LIMIT_COUNT", nil).presence || 120).to_i
  RATE_LIMIT_PERIOD = (ENV.fetch("RATE_LIMIT_PERIOD", nil).presence || 60).to_i

  throttle("/search", limit: RATE_LIMIT_COUNT, period: RATE_LIMIT_PERIOD) do |request|
    if request.path == "/search"
      request.ip
    end
  end
end
