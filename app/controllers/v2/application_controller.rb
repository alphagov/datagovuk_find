module V2
  class ApplicationController < ::ApplicationController
    before_action :set_collections
    before_action :set_data_manual_pages

    private

    def set_collections
      @collections = CollectionsService.new(nil, nil).collections_slugs
    end

    def set_data_manual_pages
      @data_manual_pages = [
        {
          title: "Who this manual is for",
          slug: "who-this-manual-is-for",
          description: "Find out if this manual can help you and why it's important."
        },
        {
          title: "Data management",
          slug: "data-management",
          description: "Understand data roles and responsibilities, and how to manage data quality."
        },
        {
          title: "Data standards",
          slug: "data-standards",
          description: "A range of standards for improving how data is used across government."
        },
        {
          title: "Security",
          slug: "security",
          description: "Strategies, policies and guidance to make your service safer."
        },
        {
          title: "Data protection and privacy",
          slug: "data-protection-and-privacy",
          description: "How to comply with the Data Protection Act 2018 and UK GDPR."
        },
        {
          title: "Data sharing",
          slug: "data-sharing",
          description: "Frameworks and guides about sharing data between government organisations."
        },
        {
          title: "AI and data-driven technologies",
          slug: "ai-and-data-driven-technologies",
          description: "How to use AI safely and effectively in government."
        },
        {
          title: "APIs and technical guidance",
          slug: "apis-and-technical-guidance",
          description: "How to build APIs in government and improve API standards."
        },
        {
          title: "General guidance",
          slug: "general-guidance",
          description: "Where to start when you're creating a new public service."
        },
        {
          title: "Get in touch",
          slug: "get-in-touch",
          description: "We’d love your feedback. Is this manual useful? Can we improve it? Complete a feedback form."
        },
        {
          title: "Join a data community",
          slug: "join-a-data-community",
          description: "Find Slack channels, events and other ways to connect with data practitioners. Learn more."
        }
      ]
    end
  end
end