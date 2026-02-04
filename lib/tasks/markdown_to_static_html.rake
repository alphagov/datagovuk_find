require Rails.root.join("app/services/dgu/markdown")

namespace :markdown do
  desc "Convert markdown to static html pages"
  task parse: :environment do
    markdown_input_dir = Rails.configuration.x.markdown_location
    markdown_output_dir = Rails.configuration.x.markdown_output_location

    markdowns = Dir.glob(Rails.root.join(markdown_input_dir).to_s)

    output_directory = Rails.root.join(markdown_output_dir)
    FileUtils.mkdir_p(output_directory)

    if markdowns.empty?
      puts("Markdown files are not present")
    end

    markdowns.each do |markdown_file|
      parsed_markdown = FrontMatterParser::Parser.parse_file(markdown_file)
      front_matter = parsed_markdown.front_matter
      content = parsed_markdown.content
      html_body = Dgu::Markdown.render(content)

      assigns = {
        title: front_matter["title"],
        collection: front_matter["collection"],
        website: front_matter["website"],
        api: front_matter["api"],
        page_last_updated: front_matter["page-last-updated"],
        tags: front_matter["tags"],
        visualisation_data: front_matter["visualisation_data"],
        contact: front_matter["contact"],
        body: html_body.html_safe,
      }

      if front_matter["collection"].nil?
        puts("Skipping markdown file #{markdown_file} as it does not have a collection in the front matter")
        next
      end

      output_path = output_directory.join(front_matter["collection"].parameterize)

      FileUtils.mkdir_p(output_path)

      html = ApplicationController.renderer.render(
        template: "collection/content",
        layout: false,
        assigns: assigns,
      )

      File.write(output_path.join(markdown_file.split("/").last.sub(".md", ".html.erb")), html)
    end

    puts("Completed parsing markdown to html/erb files")
  end
end
