class Organisation
  attr_reader :title, :name, :contact_email, :foi_name,
              :foi_email, :foi_web, :contact_name

  def initialize(hash, slug)
    capture_exception_in_sentry(slug) if hash.nil?

    @title = hash.try(:[], "title") || slug.titleize
    @name = hash.try(:[], "name") || slug
    @contact_email = hash.try(:[], "extras_contact-email")
    @contact_name = hash.try(:[], "extras_contact-name")
    @foi_email = hash.try(:[], "extras_foi-email")
    @foi_web = hash.try(:[], "extras_foi-web")
    @foi_name = hash.try(:[], "extras_foi-name")
  end

private

  def capture_exception_in_sentry(slug)
    if defined?(Sentry)
      Sentry.capture_exception(
        NotFound.new("Organisation `#{slug}` was not found in the Solr index"),
      )
    end
  end

  class NotFound < StandardError; end
end
