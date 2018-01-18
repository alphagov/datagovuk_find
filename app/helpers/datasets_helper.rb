module DatasetsHelper

  NO_MORE = {
      'discontinued' => 'Dataset no longer updated',
      'never' => 'No future updates',
      'one off' => 'No future updates',
      'default' => 'Not available'
  }

  def unescape(str)
    str = strip_tags(str).html_safe
    str = str.gsub(/&(amp;)+/, '&')
    HTMLEntities.new.decode(str)
  end

  def format(timestamp)
    Time.parse(timestamp).strftime("%d %B %Y")
  end

  def no_documents?(datafiles)
    documents(datafiles).count == 0
  end

  def documentation?(key)
    key != nil && key != ""
  end

  def last_updated_datafile(dataset)
    (dataset.datafiles.sort_by &:updated_at).last
  end

  def dataset_location(dataset)
    locations(dataset).empty? ? NO_MORE['default'] : locations(dataset)
  end

  def expected_location_class_for(dataset)
    "dgu-secondary-text" if locations(dataset).empty?
  end

  def name_of(dataset)
    dataset._source['name']
  end

  def input_box_class_for(ticket, field)
    if ticket.errors[field].any?
      "form-control form-control-2-3 form-control-error"
    else
      "form-control form-control-2-3"
    end
  end

  private

  def documents(datafiles)
    datafiles.select do |file|
      documentation?(file.documentation)
    end
  end

  def locations(dataset)
    ['location1', 'location2', 'location3']
        .map {|loc| dataset.send(loc) }
        .join(" ")
        .strip
  end

  def show_more?(datafiles, datafile)
    "js-show-more-datafiles" unless datafiles.take(5).include? datafile
  end

  def contact_details_exist?(dataset)
    contact_email_exists?(dataset) || foi_email_exists?(dataset)
  end

  def contact_email_exists?(dataset)
    dataset.contact_email.present? || dataset.organisation.contact_email.present?
  end

  def foi_email_exists?(dataset)
    dataset.foi_email.present? || dataset.organisation.foi_email.present?
  end
end
