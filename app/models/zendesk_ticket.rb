class ZendeskTicket
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  EMAIL_FORMAT = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i

  attr_accessor :name, :email, :content, :support

  validates_format_of :email, { with: EMAIL_FORMAT, message: 'Please enter a valid email address'}

  validates :name, presence: { message: 'Please enter a name'}
  validates :content, presence: { message: 'Please enter a message'}

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
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
    support == 'feedback' ? "[DGU]" : "[Data request]"
  end

end
