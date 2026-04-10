require Rails.root.join("app/services/dgu/markdown")

def format_date(date)
  return nil if date.blank?

  Date.iso8601(date).strftime("%-d/%-m/%Y")
end

def process_visualisation_data(chart_json)
  return chart_json unless chart_json["visualisation_type"] == "line"

  point_shapes = %w[circle triangle rect rectRot]

  chart_json["series"].each do |series|
    data_size = series["data"].keys.size
    next if data_size.zero?

    series["dataset"] = {
      pointRadius: Array.new(data_size - 1, 0) << 4,
      pointStyle: Array.new(data_size, point_shapes.pop || "circle"),
    }
  end

  chart_json
end

namespace :markdown do
  desc "Convert markdown to static html pages"
  task render: :environment do
    markdown_input_glob = Rails.configuration.x.markdown_collections_location_glob
    markdown_output_dir = Rails.configuration.x.markdown_collections_output_location
    visualisations_data_location = Rails.configuration.x.visualisations_data_location

    input_root = Pathname.new(Rails.root.join(markdown_input_glob.split("*").first)).cleanpath
    output_directory = Rails.root.join(markdown_output_dir)

    FileUtils.mkdir_p(output_directory)

    markdowns = Dir.glob(Rails.root.join(markdown_input_glob))

    if markdowns.empty?
      puts("No markdown files were found at #{markdown_input_glob}")
      next
    end

    markdowns.each do |markdown_file|
      parsed_markdown = FrontMatterParser::Parser.parse_file(markdown_file)
      front_matter = parsed_markdown.front_matter

      if front_matter["status"] != "for-publication"
        puts("Skipping markdown file #{markdown_file} as 'status' is missing or not 'for-publication'")
        next
      end

      content = parsed_markdown.content
      html_body = Dgu::Markdown.render(content)

      if html_body.strip.empty?
        puts("Skipping markdown file #{markdown_file} - no body content present")
        next
      end

      chart_json = nil
      if front_matter["visualisation-data"].present?
        chart_path = Rails.root.join(visualisations_data_location, front_matter["visualisation-data"])

        if File.exist?(chart_path)
          chart_data = File.read(chart_path)
          chart_json = process_visualisation_data(JSON.parse(chart_data))
        else
          puts("Warning: Visualisation data not found for #{markdown_file} - #{chart_path}")
        end
      end

      collection_topic_file_path = markdown_file.split("content").last
      collection_topic_path = collection_topic_file_path.gsub(".md", "")

      assigns = {
        title: front_matter["title"],
        websites: front_matter["websites"] || [],
        api_link: front_matter["api"],
        dataset: front_matter["dataset"],
        page_last_updated: format_date(front_matter["page-last-updated"]),
        tags: front_matter["tags"],
        visualisation_data: front_matter["visualisation-data"],
        visualisation_suffix: front_matter["visualisation-suffix"],
        min: front_matter["min_value"],
        contact: front_matter["contact"],
        body: html_body.html_safe,
        collection_topic_path: collection_topic_path,
        chart_data: chart_json,
      }

      path = Pathname.new(markdown_file)
      relative_path = path.relative_path_from(input_root).sub_ext(".html.erb")
      output_path = output_directory.join(relative_path)

      FileUtils.mkdir_p(output_path.dirname)

      unless Rails.env.test?
        puts("Rendering #{path.basename} to => #{output_path}")
      end

      html = ApplicationController.renderer.render(
        partial: "v2/collection/content",
        layout: false,
        assigns: assigns,
      )

      File.write(output_path, html)
    rescue StandardError => e
      puts("Error processing #{markdown_file}: #{e.message}")
      puts(e.backtrace.first(3).join("\n"))
    end

    puts("Completed rendering markdown to html files")
  end
end
