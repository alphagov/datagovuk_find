class ZendeskTicket
  attr_reader :ticket_details

  def initialize(ticket_details)
    @ticket_details = ticket_details
  end

  def send_ticket
    begin
      GDS_ZENDESK_CLIENT.ticket.create!(build_ticket)
    rescue => error
      Raven.capture_exception(error, extra: { ticket: ticket_details })
      Rails.logger.error "Failed to create support ticket with error: #{error.message}"
     end
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
