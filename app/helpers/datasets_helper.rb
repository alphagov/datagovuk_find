require 'uri'

module DatasetsHelper
  NO_MORE = {
      'discontinued' => 'Dataset no longer updated',
      'never' => 'No future updates',
      'one off' => 'No future updates',
      'default' => 'Not available'
  }.freeze

  def edit_dataset_url(dataset)
    URI::HTTPS.build(host: 'data.gov.uk', path: "/dataset/edit/#{dataset.legacy_name}").to_s
  end

  def displayed_date(dataset)
    if dataset.public_updated_at.present?
      dataset.public_updated_at
    elsif dataset.datafiles.none?
      dataset.last_updated_at
    else
      most_recent_datafile(dataset).updated_at
    end
  end

  def to_markdown(content)
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: false)
    markdown.render(content).html_safe
  end

  def unescape(str)
    str = strip_tags(str).html_safe
    str = str.gsub(/&(amp;)+/, '&')
    HTMLEntities.new.decode(str)
  end

  def dataset_location(dataset)
    locations(dataset).empty? ? NO_MORE['default'] : locations(dataset)
  end

  def expected_location_class_for(dataset)
    "dgu-secondary-text" if locations(dataset).empty?
  end

  def input_box_class_for(ticket, field)
    if ticket.errors[field].any?
      "form-control form-control-2-3 form-control-error"
    else
      "form-control form-control-2-3"
    end
  end

  def shorten_title(title)
    title.truncate(70, separator: ' ', omission: ' ...')
  end

  def to_json_ld(dataset)
    dataset_metadata = {
      "@context": "http://schema.org",
      "@type": "Dataset",
      name: dataset.title,
      url: "#{request.protocol}#{request.host_with_port}#{request.fullpath}",
      includedInDataCatalog: {
        "@type": "DataCatalog",
        url: "#{request.protocol}#{request.host_with_port}"
      },
      creator: {
        "@type": "Organization",
        name: dataset.organisation.title
      },
      description: dataset.summary,
      license: dataset.licence == 'uk-ogl' ? '' : dataset.licence_other,
      dateModified: displayed_date(dataset)
    }
    if dataset.licence == 'uk-ogl'
      dataset_metadata[:license] = "http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/"
    elsif dataset.licence_other
      dataset_metadata[:license] = dataset.licence_other
    end
    if dataset.topic
      dataset_metadata[:keywords] = dataset.topic['title']
    end
    files = metadata_files(dataset)
    unless files.empty?
      dataset_metadata[:distribution] = files
    end
    dataset_metadata.to_json
  end

  def metadata_files(dataset)
    files = []
    dataset.datafiles.each do |file|
      files.push(
        "@type": 'DataDownload',
        contentUrl: file.url,
        fileFormat: file.format,
        name: file.name
      )
    end
    files
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

  def foi_email_for(dataset)
    dataset.foi_email.presence || dataset.organisation.foi_email
  end

  def foi_web_address_for(dataset)
    (dataset.foi_web.presence || dataset.organisation.foi_web).to_s
  end

private

  def locations(dataset)
    %w[location1 location2 location3]
        .map { |loc| dataset.send(loc) }
        .join(" ")
        .strip
  end

  def most_recent_datafile(dataset)
    dataset.datafiles.sort_by(&:created_at).last
  end
end
