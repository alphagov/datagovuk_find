class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception, prepend: true
  before_action :restrict_request_format
  rescue_from SolrDataset::NotFound, with: :render_not_found
  rescue_from SolrDatafile::NotFound, with: :render_not_found
  before_action :set_collections
  before_action :set_data_manual_pages
  before_action :set_data_manual_menu_items

  rescue_from RSolr::Error::ConnectionRefused do |exception|
    Sentry.capture_exception(exception) if defined?(Sentry)

    render "errors/service_unavailable_error", status: :service_unavailable
  end

  def render_not_found
    render "errors/not_found", status: :not_found
  end

  def restrict_request_format
    request.format = :html
  end

private

  def set_collections
    @collections = [
      {
        title: "Business and economy",
        slug: "business-and-economy",
        description: "Company information, economic indicators, markets",
      },
      {
        title: "Environment",
        slug: "environment",
        description: "Nature, conservation, climate, and sustainability",
      },
      {
        title: "Government",
        slug: "government",
        description: "Political systems, policies, and public administration",
      },
      {
        title: "Land and property",
        slug: "land-and-property",
        description: "Housing, land use, and property rights",
      },
      {
        title: "People",
        slug: "people",
        description: "Population, immigration and emmigration, health",
      },
      {
        title: "Transport",
        slug: "transport",
        description: "Public transport, cars, cycling and walking",
      },
    ]
  end

  def set_data_manual_pages
    @data_manual_pages = [
      {
        title: "Who this manual is for",
        url: "/data-manual/who-this-manual-is-for",
        description: "Find out if this manual can help you and why it's important",
        icon: "user",
      },
      {
        title: "Data management",
        url: "/data-manual/data-management",
        description: "Understand data roles and responsibilities, and how to manage data quality",
        icon: "database",
      },
      {
        title: "Data standards",
        url: "/data-manual/data-standards",
        description: "A range of standards for improving how data is used across government",
        icon: "document",
      },
      {
        title: "Security",
        url: "/data-manual/security",
        description: "Strategies, policies and guidance to make your service safer",
        icon: "padlock",
      },
      {
        title: "Data protection and privacy",
        url: "/data-manual/data-protection-and-privacy",
        description: "How to comply with the Data Protection Act 2018 and UK GDPR",
        icon: "shield",
      },
      {
        title: "Data sharing",
        url: "/data-manual/data-sharing",
        description: "Frameworks and guides about sharing data between government organisations",
        icon: "sharing",
      },
      {
        title: "AI and data-driven technologies",
        url: "/data-manual/ai-and-data-driven-technologies",
        description: "How to use AI safely and effectively in government",
        icon: "stars",
      },
      {
        title: "APIs and technical guidance",
        url: "/data-manual/apis-and-technical-guidance",
        description: "How to build APIs in government and improve API standards",
        icon: "api",
      },
      {
        title: "General guidance",
        url: "/data-manual/general-guidance",
        description: "Where to start when you're creating a new public service",
        icon: "open-book",
      },
    ]
  end

  def set_data_manual_menu_items
    @data_manual_menu_items = [
      *@data_manual_pages,
      {
        title: "Tell us what you think",
        url: "https://forms.office.com/e/9V26PNFQaR",
        description: "We’d love your feedback. Is this manual useful? Can we improve it? Complete a feedback form.",
      },
      {
        title: "Join a data community",
        url: "/data-manual/join-a-data-community",
        description: "Find Slack channels, events and other ways to connect with data practitioners. Learn more.",
      },
    ]
  end
end
