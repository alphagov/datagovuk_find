require 'zendesk_api'

class ZendeskTicket
  attr_reader :ticket_details, :client

  def initialize(ticket_details)
    @ticket_details = ticket_details
    @client = ZendeskAPI::Client.new do |config|
      config.username = ENV["ZENDESK_USERNAME"]
      config.token = ENV["ZENDESK_API_KEY"]
      config.password = ENV["ZENDESK_PASSWORD"]
      config.url = ENV["ZENDESK_ENDPOINT"]
    end
  end

  def send_ticket
    ZendeskAPI::Ticket.create!(client, build_ticket)
  end

  private

  def build_ticket
    { "requester": {"name": ticket_details[:name], "email": ticket_details[:email]},
      "subject": support_queue + " Find Data Beta support request",
      "comment": {"body": ticket_details[:content]}
    }
  end

  def support_queue
    ticket_details[:support] == 'feedback' ? "[DGU]" : "[Data request]"
  end

end
