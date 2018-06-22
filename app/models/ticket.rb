class Ticket
  include ActiveModel::Model

  attr_accessor :name, :email, :content, :support

  validates_format_of :email, with: /\A[^@]+@[^@]+\z/, message: 'Enter a valid email address'
  validates :name, presence: { message: 'Enter a name' }
  validates :content, presence: { message: 'Enter a message' }

  def initialize(ticket_details = {})
    @email = ticket_details[:email]
    @name = ticket_details[:name]
    @content = ticket_details[:content]
    @support = ticket_details[:support]
  end

  def to_json
    { "requester": { "name": name, "email": email },
      "subject": support_queue + " Find open data - #{support} request",
      "comment": { "body": content } }
  end

  def support_queue
    support == 'data' ? "[Data request]" : "[DGU]"
  end
end
