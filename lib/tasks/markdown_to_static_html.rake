require Rails.root.join("app/services/dgu/markdown")

namespace :markdown do
  desc "Convert markdown to static html pages"
  task render: :environment do
    markdown_input_glob = Rails.configuration.x.markdown_collections_location_glob
    markdown_output_dir = Rails.configuration.x.markdown_collections_output_location

    input_root = Pathname.new(Rails.root.join(markdown_input_glob.split("*").first)).cleanpath
    markdowns = Dir.glob(Rails.root.join(markdown_input_glob).to_s)

    output_directory = Rails.root.join(markdown_output_dir)
    FileUtils.mkdir_p(output_directory)

    if markdowns.empty?
      puts("No markdown files were found")
    end

    markdowns.each do |markdown_file|
      parsed_markdown = FrontMatterParser::Parser.parse_file(markdown_file)
      front_matter = parsed_markdown.front_matter
      content = parsed_markdown.content
      html_body = Dgu::Markdown.render(content)

      if html_body.strip.empty?
        puts("Skipping markdown file #{markdown_file} no body content present")
        next
      end

      assigns = {
        title: front_matter["title"],
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

      path = Pathname.new(markdown_file)
      relative_path = path.relative_path_from(input_root).sub_ext(".html.erb")
      output_path = output_directory / relative_path
      FileUtils.mkdir_p(output_path.dirname)

      puts("Render #{path.basename} to => #{output_path}")

      html = ApplicationController.renderer.render(
        partial: "v2/collection/content",
        layout: false,
        assigns: assigns,
      )

      File.write(output_path, html)
    rescue StandardError => e
      puts("error processing #{markdown_file}")
      puts e
    end
    puts("Completed rendering markdown to html files")
  end
end
