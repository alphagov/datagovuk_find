class TicketsController < ApplicationController
  def new
    @support_queue = params['support']
    @ticket = ZendeskTicket.new
  end

  def create
    @ticket = ZendeskTicket.new(params[:zendesk_ticket])
    if @ticket.valid?
      @ticket.send_ticket
      redirect_to tickets_confirmation_path
    else
      render :new
    end
  end
end
