class ZendeskTicket
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :name, :email, :content, :support

  validates_format_of :email, { with: /\A[^@]+@[^@]+\z/, message: 'Enter a valid email address'}

  validates :name, presence: { message: 'Enter a name'}
  validates :content, presence: { message: 'Enter a message'}

  def initialize(ticket_details = {})
    @email = ticket_details[:email]
    @name = ticket_details[:name]
    @content = ticket_details[:content]
    @support = ticket_details[:support]
  end

  def send_ticket
    begin
      GDS_ZENDESK_CLIENT.tickets.create!(build_ticket)
    rescue => error
      Raven.capture_exception(error, extra: { ticket: build_ticket })
      Rails.logger.error "Failed to create support ticket with error: #{ error.message }"
     end
  end

  def persisted?
    false
  end

  private

  def build_ticket
      { "requester": { "name": name, "email": email },
        "subject": support_queue + " Find Data Beta support request",
        "comment": {"body": content}
      }
  end

  def support_queue
    support == 'data' ? "[Data request]" : "[DGU]"
  end

end
