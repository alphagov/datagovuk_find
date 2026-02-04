module Dgu
  class MarkdownRenderer < ::Redcarpet::Render::HTML
    include Redcarpet::Render::SmartyPants

    def initialize(govuk_options, options = {})
      @headings_start_with = govuk_options[:headings_start_with]
      @strip_front_matter = options[:strip_front_matter]

      super options
    end

    def table(header, body)
      <<~HTML
        <table class='govuk-table'>
          <thead class='govuk-table__head'>
            #{header}
          </thead>
          <tbody class='govuk-table__body'>
            #{body}
          </tbody>
        </table>
      HTML
    end

    def table_row(content)
      <<~HTML
        <tr class='govuk-table__row'>
          #{content}
        </tr>
      HTML
    end

    def table_cell(content, _alignment, header)
      if header
        <<~HTML
          <th class='govuk-table__header'>
            #{content}
          </th>
        HTML
      else
        <<~HTML
          <td class='govuk-table__cell'>
            #{content}
          </td>
        HTML
      end
    end

    def header(text, header_level)
      valid_header_sizes = %w[xl l m s].freeze

      start_size = valid_header_sizes.include?(@headings_start_with) ? @headings_start_with : "xl"

      start_size_index = valid_header_sizes.find_index(start_size)

      header_size = valid_header_sizes[start_size_index + header_level - 1] || "s"

      # TODO: with_toc_data is add HTML anchors to each header in the output HTML, to allow linking to each section
      id_attribute = @options[:with_toc_data] ? " id=\"#{text.parameterize}\"" : ""
      <<~HTML
        <h#{header_level}#{id_attribute} class="govuk-heading-#{header_size}">#{text}</h#{header_level}>
      HTML
    end

    def paragraph(text)
      <<~HTML
        <p class="govuk-body-m">#{text}</p>
      HTML
    end

    def list(contents, list_type)
      case list_type
      when :unordered
        <<~HTML
          <ul class="govuk-list govuk-list--bullet">
            #{contents}
          </ul>
        HTML
      when :ordered
        <<~HTML
          <ol class="govuk-list govuk-list--number">
            #{contents}
          </ol>
        HTML
      else
        raise "Unexpected type #{list_type.inspect}"
      end
    end

    def hrule
      <<~HTML
        <hr class="govuk-section-break govuk-section-break--xl govuk-section-break--visible">
      HTML
    end

    def preprocess(document)
      Preprocessor
        .new(document)
        .inject_inset_text
        .inject_details
        .strip_front_matter(@strip_front_matter)
        .output
    end
  end
end
