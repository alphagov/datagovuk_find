class ZendeskDummyClient
  attr_reader :tickets

  def initialize
    @tickets = ZendeskDummyTicket.new
  end

end

class ZendeskDummyTicket

  def create!(args)
    {
      response: { status: 200,
                  body: 'ticket created' }
    }
  end

end
