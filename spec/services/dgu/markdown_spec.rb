require "rails_helper"

RSpec.describe Dgu::Markdown do
  describe ".render" do
    it "renders markdown to HTML" do
      markdown = <<~MD
        # Heading

        This is **bold** text.
      MD

      expected_html = <<~HTML
        <h1 id="heading" class="govuk-heading-xl">Heading</h1>
        <p class="govuk-body-m">This is <strong>bold</strong> text.</p>
      HTML

      rendered_html = Dgu::Markdown.render(markdown)

      expect(rendered_html).to eq(expected_html.strip)
    end

    it "handles links" do
      markdown = <<~MD
        [Test](https://www.test.com)
      MD

      expected_html = <<~HTML
        <p class="govuk-body-m"><a href="https://www.test.com" class="govuk-link">Test</a></p>
      HTML

      rendered_html = Dgu::Markdown.render(markdown).strip

      expect(rendered_html).to eq(expected_html.strip)
    end

    it "processes lists" do
      markdown = <<~MD
        - Item 1
        - Item 2
        - Item 3
      MD

      expected_html = <<~HTML
        <ul class="govuk-list govuk-list--bullet">
          <li>Item 1</li>
        <li>Item 2</li>
        <li>Item 3</li>

        </ul>
      HTML

      rendered_html = Dgu::Markdown.render(markdown)

      expect(rendered_html).to eq(expected_html.strip)
    end

    it "converts blockquotes" do
      markdown = <<~MD
        > This is a blockquote.
      MD

      expected_html = <<~HTML
        <blockquote>
        <p class="govuk-body-m">This is a blockquote.</p>
        </blockquote>
      HTML

      rendered_html = Dgu::Markdown.render(markdown).strip

      expect(rendered_html).to eq(expected_html.strip)
    end

    it "handles code blocks" do
      markdown = <<~MD
        ```
        def hello_world
          puts 'Hello, world!'
        end
        ```
      MD

      expected_html = <<~HTML
        <p class="govuk-body-m"><code>
        def hello_world
          puts &#39;Hello, world!&#39;
        end
        </code></p>
      HTML

      rendered_html = Dgu::Markdown.render(markdown).strip

      expect(rendered_html).to eq(expected_html.strip)
    end
  end
end
