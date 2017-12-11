class SupportController < LoggedAreaController

  def submit
    @support_queue = params['support']
    @ticket = ZendeskTicket.new
  end

  def ticket
    @ticket = ZendeskTicket.new(params[:zendesk_ticket])

    if @ticket.valid?
      @ticket.send_ticket
      redirect_to support_confirmation_path
    else
      render :submit
    end
  end

end
