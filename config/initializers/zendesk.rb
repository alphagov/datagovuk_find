module Zendesk
  def self.client
    return DummyClient.instance if Rails.env.development?
    return DummyClient.instance if Rails.env.test?

    ZendeskAPI::Client.new do |config|
      config.username = ENV['ZENDESK_USERNAME']
      config.token = ENV['ZENDESK_API_KEY']
      config.url = ENV['ZENDESK_END_POINT']
    end
  end

  class DummyClient
    def self.instance
      @instance ||= self.new
    end

    def tickets
      DummyTickets.instance
    end
  end

  class DummyTickets
    def self.instance
      @instance ||= self.new
    end

    def create!(_arg); end
  end
end
