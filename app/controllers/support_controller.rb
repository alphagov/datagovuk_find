class SupportController < LoggedAreaController
  skip_before_action :verify_authenticity_token

  def submit
    @support_queue = params['support']
  end

  def ticket
    create_zendesk_ticket(params)
    redirect_to support_confirmation_path
  end

  private

  def create_zendesk_ticket(ticket_details)
    ZendeskTicket.new(ticket_details).send_ticket
  end

end
