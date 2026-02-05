require "active_support/all"
require "redcarpet"

require_relative "./preprocessor"
require_relative "./markdown_renderer"

module Dgu
  class Markdown
    def self.render(markdown, govuk_options = {})
      renderer = MarkdownRenderer.new(govuk_options, { with_toc_data: true, strip_front_matter: true, link_attributes: { class: "govuk-link" } })
      Redcarpet::Markdown.new(renderer, tables: true, no_intra_emphasis: true).render(markdown).strip
    end
  end
end
