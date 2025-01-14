require "uri"

module DatasetsHelper
  def to_markdown(content)
    return "Not provided" if content.nil?

    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: false)
    markdown.render(content).html_safe
  end

  def unescape(str)
    str = strip_tags(str).html_safe
    str = str.gsub(/&(amp;)+/, "&")
    HTMLEntities.new.decode(str)
  end

  def shorten_title(title)
    title.truncate(70, separator: " ", omission: " ...")
  end

  def contact_information_exists?(dataset)
    contact_email_exists?(dataset) || foi_details_exist?(dataset)
  end

  def contact_email_exists?(dataset)
    contact_email_for(dataset).present?
  end

  def contact_name_for(dataset)
    dataset.contact_name.presence || dataset.organisation.contact_name
  end

  def contact_email_is_email?(dataset)
    contact_email_for(dataset) =~ /@/
  end

  def contact_email_for(dataset)
    dataset.contact_email.presence || dataset.organisation.contact_email
  end

  def foi_details_exist?(dataset)
    foi_email_exists?(dataset) || foi_web_address_exists?(dataset)
  end

  def foi_email_exists?(dataset)
    foi_email_for(dataset).present?
  end

  def foi_web_address_exists?(dataset)
    foi_web_address_for(dataset).present?
  end

  def foi_name_for(dataset)
    dataset.foi_name.presence || dataset.organisation.foi_name
  end

  def foi_email_is_email?(dataset)
    foi_email_for(dataset) =~ /@/
  end

  def foi_email_for(dataset)
    dataset.foi_email.presence || dataset.organisation.foi_email
  end

  def foi_web_address_for(dataset)
    (dataset.foi_web.presence || dataset.organisation.foi_web).to_s
  end
end
