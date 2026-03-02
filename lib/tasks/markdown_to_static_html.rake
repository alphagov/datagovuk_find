require Rails.root.join("app/services/dgu/markdown")

namespace :markdown do
  desc "Convert markdown to static html pages"
  task parse: :environment do
    markdown_input_glob = Rails.configuration.x.markdown_collecitons_location_glob
    markdown_output_dir = Rails.configuration.x.markdown_collections_output_location

    markdowns = Dir.glob(Rails.root.join(markdown_input_glob).to_s)

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
        websites: front_matter["websites"] || [],
        api_link: front_matter["api"],
        dataset: front_matter["dataset"],
        page_last_updated: front_matter["page-last-updated"],
        tags: front_matter["tags"],
        visualisation_data: front_matter["visualisation-data"],
        contact: front_matter["contact"],
        body: html_body.html_safe,
      }

      if front_matter["status"].nil? || front_matter["status"] != "for-publication"
        puts("Skipping markdown file #{markdown_file} as 'status' is missing or not 'for-publication' ")
        next
      end

      output_path = output_directory.join(front_matter["collection"].parameterize)

      FileUtils.mkdir_p(output_path)

      html = ApplicationController.renderer.render(
        partial: "v2/collection/content",
        layout: false,
        assigns: assigns,
      )

      File.write(output_path.join(markdown_file.split("/").last.sub(".md", ".html.erb")), html)
    rescue StandardError
      puts("error processing #{markdown_file}")
    end
    puts("Completed rendering markdown to html files")
  end
end
