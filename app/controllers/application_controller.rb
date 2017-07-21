class ApplicationController < ActionController::Base
  httpauth_name = ENV.fetch('FIND_USERNAME', rand(100000000).to_s)
  httpauth_pass = ENV.fetch('FIND_PASSWORD', rand(100000000).to_s)
  http_basic_authenticate_with name: httpauth_name, password: httpauth_pass
  protect_from_forgery with: :exception
end
