module Dgu
  class Preprocessor
    attr_reader :output

    def initialize(document)
      @output = document
    end

    def inject_inset_text
      @output = output.gsub(build_regexp("inset-text")) do
        <<~HTML
          <div class="govuk-inset-text">
            #{nested_markdown(Regexp.last_match(1))}
          </div>
        HTML
      end
      self
    end

    def inject_details
      @output = output.gsub(build_regexp("details")) do
        summary, details = *construct_details_from(Regexp.last_match(1))

        <<~HTML
          <details class="govuk-details" data-module="govuk-details">
            <summary class="govuk-details__summary">
              <span class="govuk-details__summary-text">
              #{summary}
              </span>
            </summary>
            <div class="govuk-details__text">
              #{nested_markdown(details)}
            </div>
          </details>
        HTML
      end
      self
    end

    def strip_front_matter(enabled)
      return self unless enabled

      @output = output.gsub(%r{^---\n.*\n---}m, "")

      self
    end

  private

    def nested_markdown(content)
      return content unless content =~ /\n/

      Markdown.render(content)
    end

    def build_regexp(tag_name, pre_tag: "{", post_tag: "}", closing: "/")
      start_tag = pre_tag + tag_name + post_tag
      end_tag = pre_tag + closing + tag_name + post_tag
      pattern = [Regexp.quote(start_tag), "(.*?)", Regexp.quote(end_tag)].join

      Regexp.compile(pattern, Regexp::EXTENDED | Regexp::MULTILINE)
    end

    def construct_details_from(match_string, partition_characters: %w[? .])
      summary_text, match, details = match_string.partition(Regexp.union(*partition_characters))

      summary = [summary_text, format_punctuation(match)].compact.join

      [summary, details].compact.map(&:strip)
    end

    def format_punctuation(match)
      return if match.include?(".")

      match
    end
  end
end
