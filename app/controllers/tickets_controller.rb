class TicketsController < ApplicationController
  def new
    @ticket = Ticket.new(support: params['support'])
  end

  def create
    @ticket = Ticket.new(params[:ticket])

    if @ticket.valid?
      client.tickets.create!(@ticket.to_json)
      redirect_to tickets_confirmation_path
    else
      render :new
    end
  end

private

  def client
    Zendesk.client
  end
end
