class Organisation
  attr_reader :title, :name, :contact_email, :foi_name,
              :foi_email, :foi_web, :contact_name

  def initialize(hash)
    @title = hash['title']
    @name = hash['name']
    @contact_email = hash['contact_email']
    @contact_name = hash['contact_name']
    @foi_email = hash['foi_email']
    @foi_web = hash['foi_web']
    @foi_name = hash['foi_name']
  end
end
