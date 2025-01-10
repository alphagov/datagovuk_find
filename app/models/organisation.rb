class Organisation
  attr_reader :title, :name, :contact_email, :foi_name,
              :foi_email, :foi_web, :contact_name

  def initialize(hash)
    @title = hash["title"]
    @name = hash["name"]
    @contact_email = hash["extras_contact-email"]
    @contact_name = hash["extras_contact-name"]
    @foi_email = hash["extras_foi-email"]
    @foi_web = hash["extras_foi-web"]
    @foi_name = hash["extras_foi-name"]
  end
end
