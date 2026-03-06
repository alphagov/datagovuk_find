require "active_support/all"
require "redcarpet"

require_relative "./preprocessor"
require_relative "./markdown_renderer"

module Dgu
  class MarkdownContentNotFound < LoadError
  end

  class Markdown
    def self.render(markdown, govuk_options = {})
      renderer = MarkdownRenderer.new(govuk_options, { with_toc_data: true, strip_front_matter: true, link_attributes: { class: "govuk-link" } })
      Redcarpet::Markdown.new(renderer, tables: true, no_intra_emphasis: true).render(markdown).strip
    end

    def self.render_from_file(markdown_file_directory, markdown_file_slug)
      # NOTE: the below brakeman complaint is happening because brakeman cannot verify that our config
      #   variable does not contain a leading /.  Ignoring it.
      # brakeman: disable: Rails/DynamicRenderPath, Rails/FileAccess
      markdown_file = Rails.root.join(markdown_file_directory, "#{markdown_file_slug}.md")
      if File.exist?(markdown_file)
        markdown = File.read(markdown_file)
      else
        raise MarkdownContentNotFound
      end
      Dgu::Markdown.render(markdown).html_safe
    end
      
  end
end
