def authenticate_browser
  page.driver.browser.authorize(ENV['HTTP_USERNAME'], ENV['HTTP_PASSWORD'])
end

def authenticate
  @request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(ENV['HTTP_USERNAME'], ENV['HTTP_PASSWORD'])
end
