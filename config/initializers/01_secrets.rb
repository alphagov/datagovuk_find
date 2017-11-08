# Early exit if VCAP_SERVICES is not found
return unless ENV["VCAP_SERVICES"]

# Attempt to find user provided services
services = JSON.parse(ENV["VCAP_SERVICES"])
return unless services.keys.include?('user-provided')

# Extract UPSes and pull out secrets configs
user_provided_services = services['user-provided'].select { |s| s['name'].include?('secrets') }
credentials = user_provided_services.map { |s| s['credentials'] }.reduce(:merge)

# Take each credential and assign to ENV
credentials.each do |k, v|
  # Don't overwrite existing env vars
  ENV[k.upcase] ||= v
end
