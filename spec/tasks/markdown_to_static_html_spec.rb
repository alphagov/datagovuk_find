require "rake"
require "rails_helper"

RSpec.describe "Markdown to Static HTML Rake Task", type: :task do
  before(:all) do
    Rake.application.rake_require("tasks/markdown_to_static_html")
    Rake::Task.define_task(:environment)
  end

  let(:task) { Rake::Task["markdown:render"] }

  let(:tmp_workspace) { Rails.root.join("tmp/markdown_task_spec") }
  let(:input_dir) { tmp_workspace.join("content/collections") }
  let(:output_dir) { tmp_workspace.join("generated") }
  let(:chart_dir) { tmp_workspace.join("charts") }

  before do
    FileUtils.mkdir_p(input_dir)
    FileUtils.mkdir_p(output_dir)
    FileUtils.mkdir_p(chart_dir)
    allow(Rails.configuration.x).to receive(:markdown_collections_location_glob).and_return("#{input_dir}/**/*.md")
    allow(Rails.configuration.x).to receive(:markdown_collections_output_location).and_return(output_dir.to_s)
    allow(Rails.configuration.x).to receive(:visualisations_data_location).and_return(chart_dir.to_s)
    allow_any_instance_of(ActionController::Renderer).to receive(:render).and_return("<html>Rendered Output</html>")
  end

  after do
    FileUtils.rm_rf(tmp_workspace)
  end

  describe "File filtering and skipping" do
    it "skips files that are not for-publication" do
      create_markdown_file("draft_page", status: "draft")

      task.reenable
      expect { task.invoke }.to output(/Skipping markdown file.*status' is missing or not/).to_stdout
      expect(Dir.glob(File.join(output_dir, "**/*.html.erb"))).to be_empty
    end

    it "skips files with an empty body" do
      create_markdown_file("empty_page", body: "")

      task.reenable
      expect { task.invoke }.to output(/Skipping markdown file.*no body content present/).to_stdout
    end
  end

  describe "successfully renders markdown files" do
    before do
      create_markdown_file("valid_page", status: "for-publication")
      nested_dir = input_dir.join("nested-collection")
      FileUtils.mkdir_p(nested_dir)
      File.write(nested_dir.join("nested_page.md"), front_matter_template("nested_page", "for-publication", "Valid Content"))
    end

    it "renders all markdown files" do
      create_markdown_file("another_valid_page", status: "for-publication")

      task.reenable
      task.invoke

      expect(Dir.glob(File.join(output_dir, "**/*.html.erb")).size).to eq(3)
    end

    it "renders markdown content into HTML" do
      task.reenable
      task.invoke

      generated_file = output_dir.join("valid_page.html.erb")
      expect(File).to exist(generated_file)
      content = File.read(generated_file)
      expect(content).to include("<html>Rendered Output</html>")
    end

    it "maintains the directory structure for nested markdown files" do
      task.reenable
      task.invoke

      nested_generated_file = output_dir.join("nested-collection/nested_page.html.erb")
      expect(File).to exist(nested_generated_file)
    end
  end

  describe "Visualisation data injection" do
    it "modifies line chart series data with pointRadius and pointStyle" do
      chart_json = { "visualisation_type" => "line", "series" => [{ "data" => { "2020" => 1, "2021" => 2 } }] }
      File.write(chart_dir.join("test_chart.json"), chart_json.to_json)

      create_markdown_file("chart_page", status: "for-publication", extra_front_matter: "visualisation-data: test_chart.json")

      expect_any_instance_of(ActionController::Renderer).to receive(:render) do |_, args|
        series = args[:assigns][:chart_data]["series"].first
        expect(series["dataset"][:pointRadius]).to eq([0, 4]) # n-1 zeros, then a 4
        expect(series["dataset"][:pointStyle].length).to eq(2)
        "fake html"
      end

      task.reenable
      task.invoke
    end
  end

  def create_markdown_file(title, status: "for-publication", body: "# Sample Content", extra_front_matter: "")
    path = input_dir.join("#{title}.md")
    File.write(path, front_matter_template(title, status, body, extra_front_matter))
    path
  end

  def front_matter_template(title, status, body, extra_front_matter = "")
    <<~MARKDOWN
      ---
      title: #{title}
      status: #{status}
      #{extra_front_matter}
      ---
      #{body}
    MARKDOWN
  end
end
