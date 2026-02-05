require "rails_helper"

RSpec.describe Dgu::Preprocessor do
  describe ".initialize" do
    it "sets the output to the provided document" do
      document = "Sample document"
      preprocessor = Dgu::Preprocessor.new(document)

      expect(preprocessor.output).to eq(document)
    end
  end
  describe "#inject_inset_text" do
    it "replaces inset-text tags with govuk-inset-text HTML" do
      document = "{inset-text}This is an inset text.{/inset-text}"
      preprocessor = Dgu::Preprocessor.new(document)
      preprocessor.inject_inset_text

      expected_output = <<~HTML
        <div class="govuk-inset-text">
          This is an inset text.
        </div>
      HTML

      expect(preprocessor.output.strip).to eq(expected_output.strip)
    end
  end
  describe "#inject_details" do
    it "replaces details tags with govuk-details HTML" do
      document = "{details}Summary.\nContent.{/details}"
      preprocessor = Dgu::Preprocessor.new(document)
      preprocessor.inject_details

      expected_output = <<~HTML
        <details class="govuk-details" data-module="govuk-details">
          <summary class="govuk-details__summary">
            <span class="govuk-details__summary-text">
            Summary
            </span>
          </summary>
          <div class="govuk-details__text">
            Content.
          </div>
        </details>
      HTML

      expect(preprocessor.output.strip).to eq(expected_output.strip)
    end

    it "handles details without a newline" do
      document = "{details}Summary without content.{/details}"
      preprocessor = Dgu::Preprocessor.new(document)
      preprocessor.inject_details

      expected_output = <<~HTML
        <details class="govuk-details" data-module="govuk-details">
          <summary class="govuk-details__summary">
            <span class="govuk-details__summary-text">
            Summary without content
            </span>
          </summary>
          <div class="govuk-details__text">
        #{'    '}
          </div>
        </details>
      HTML

      expect(preprocessor.output.strip).to eq(expected_output.strip)
    end

    it "handles multiple details tags" do
      document = "{details}First summary.\nFirst content.{/details}\n{details}Second summary.\nSecond content.{/details}"
      preprocessor = Dgu::Preprocessor.new(document)
      preprocessor.inject_details

      expected_output = <<~HTML
        <details class="govuk-details" data-module="govuk-details">
          <summary class="govuk-details__summary">
            <span class="govuk-details__summary-text">
            First summary
            </span>
          </summary>
          <div class="govuk-details__text">
            First content.
          </div>
        </details>

        <details class="govuk-details" data-module="govuk-details">
          <summary class="govuk-details__summary">
            <span class="govuk-details__summary-text">
            Second summary
            </span>
          </summary>
          <div class="govuk-details__text">
            Second content.
          </div>
        </details>
      HTML

      expect(preprocessor.output.strip).to eq(expected_output.strip)
    end

    it "handles no details tags" do
      document = "This document has no details tags."
      preprocessor = Dgu::Preprocessor.new(document)
      preprocessor.inject_details

      expect(preprocessor.output).to eq(document)
    end
  end

  describe "#strip_front_matter" do
    it "removes front matter when enabled" do
      document = <<~DOC
        ---
        title: Title
        ---
        Content of the document.
      DOC
      preprocessor = Dgu::Preprocessor.new(document)
      preprocessor.strip_front_matter(true)
      expected_output = "\nContent of the document.\n"
      expect(preprocessor.output).to eq(expected_output)
    end
  end
end
