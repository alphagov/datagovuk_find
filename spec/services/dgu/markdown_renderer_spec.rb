require "rails_helper"

RSpec.describe Dgu::MarkdownRenderer do
  let(:govuk_options) { { headings_start_with: "dgu-" } }
  let(:markdown_options) { { strip_front_matter: true } }
  let(:renderer) { Dgu::MarkdownRenderer.new(govuk_options, markdown_options) }

  describe ".initialize" do
    it "initializes with govuk options and markdown options" do
      expect(renderer).to be_a(Dgu::MarkdownRenderer)
    end

    it "sets default values when options are not provided" do
      expect(renderer.instance_variable_get(:@headings_start_with)).to eq("dgu-")
      expect(renderer.instance_variable_get(:@strip_front_matter)).to eq(true)
    end
  end

  describe "#table" do
    it "renders a table with govuk-table class" do
      header = "<tr><th>Header 1</th><th>Header 2</th></tr>"
      body = "<tr><td>Data 1</td><td>Data 2</td></tr>"

      result = renderer.table(header, body)

      expected_html = <<~HTML
        <table class='govuk-table'>
          <thead class='govuk-table__head'>
            #{header}
          </thead>
          <tbody class='govuk-table__body'>
            #{body}
          </tbody>
        </table>
      HTML

      expect(result).to eq(expected_html)
    end
  end
  describe "#table_row" do
    it "renders a table row" do
      renderer = Dgu::MarkdownRenderer.new({}, {})
      content = "<td>Data 1</td><td>Data 2</td>"

      result = renderer.table_row(content)

      expected_html = <<~HTML
        <tr class='govuk-table__row'>
          #{content}
        </tr>
      HTML

      expect(result).to eq(expected_html)
    end

    it "renders a table row with header cells" do
      renderer = Dgu::MarkdownRenderer.new({}, {})
      content = "<th>Header 1</th><th>Header 2</th>"

      result = renderer.table_row(content)

      expected_html = <<~HTML
        <tr class='govuk-table__row'>
          #{content}
        </tr>
      HTML

      expect(result).to eq(expected_html)
    end

    it "renders a table row with mixed cells" do
      renderer = Dgu::MarkdownRenderer.new({}, {})
      content = "<th>header</th><td>Some info</td>"

      result = renderer.table_row(content)

      expected_html = <<~HTML
        <tr class='govuk-table__row'>
          #{content}
        </tr>
      HTML

      expect(result).to eq(expected_html)
    end

    it "renders an empty table row" do
      renderer = Dgu::MarkdownRenderer.new({}, {})
      content = ""

      result = renderer.table_row(content)

      expected_html = <<~HTML
        <tr class='govuk-table__row'>
          #{content}
        </tr>
      HTML

      expect(result).to eq(expected_html)
    end
  end
  describe "#table_cell" do
    it "renders a table cell" do
      content = "Table cell content"
      header = true

      result = renderer.table_cell(content, nil, header)

      expected_html = <<~HTML
        <th class='govuk-table__header'>
          #{content}
        </th>
      HTML

      expect(result).to eq(expected_html)
    end
  end
  describe "#header" do
    it "renders a header with govuk-heading class" do
      renderer = Dgu::MarkdownRenderer.new({}, {})
      text = "Header Text"
      level = 2

      result = renderer.header(text, level)

      expected_html = <<~HTML
        <h2 class="govuk-heading-l">#{text}</h2>
      HTML

      expect(result).to eq(expected_html)
    end
  end
  describe "#paragraph" do
    it "renders a paragraph with govuk-body class" do
      renderer = Dgu::MarkdownRenderer.new({}, {})
      text = "This is a paragraph."

      result = renderer.paragraph(text)

      expected_html = <<~HTML
        <p class="govuk-body-m">#{text}</p>
      HTML

      expect(result).to eq(expected_html)
    end
  end
  describe "#list" do
    context "when list_type is :unordered" do
      it "renders an unordered list with govuk-list class" do
        body = "<li>Item 1</li><li>Item 2</li>"

        result = renderer.list(body, :unordered)

        expected_html = <<~HTML
          <ul class="govuk-list govuk-list--bullet">
            #{body}
          </ul>
        HTML

        expect(result).to eq(expected_html)
      end
    end
    context "when list_type is :ordered" do
      it "renders an ordered list with govuk-list class" do
        body = "<li>First</li><li>Second</li>"

        result = renderer.list(body, :ordered)

        expected_html = <<~HTML
          <ol class="govuk-list govuk-list--number">
            #{body}
          </ol>
        HTML
        expect(result).to eq(expected_html)
      end
    end

    context "when list_type is unknown" do
      it "returns an empty string" do
        body = "<li>Item</li>"

        expect {
          renderer.list(body, :unknown)
        }.to raise_error("Unexpected type :unknown")
      end
    end
  end

  describe "#hrule" do
    it "renders a horizontal rule with govuk-section-break class" do
      renderer = Dgu::MarkdownRenderer.new({}, {})

      result = renderer.hrule

      expected_html = <<~HTML
        <hr class="govuk-section-break govuk-section-break--xl govuk-section-break--visible">
      HTML

      expect(result).to eq(expected_html)
    end
  end
  describe "#preprocess" do
    it "applies preprocessors to the text" do
      markdown = <<~MD
        {inset-text}
        This is an inset text.
        {/inset-text}

        {details}
        Summary Text.

        Detailed content goes here.
        {/details}
      MD

      expected_html = <<~HTML
        <div class="govuk-inset-text">
          <p class="govuk-body-m">This is an inset text.</p>
        </div>


        <details class="govuk-details" data-module="govuk-details">
          <summary class="govuk-details__summary">
            <span class="govuk-details__summary-text">
            Summary Text
            </span>
          </summary>
          <div class="govuk-details__text">
            Detailed content goes here.
          </div>
        </details>
      HTML

      renderer = Dgu::MarkdownRenderer.new({}, {})
      result = renderer.send(:preprocess, markdown)

      expect(result.strip).to eq(expected_html.strip)
    end
  end
end
