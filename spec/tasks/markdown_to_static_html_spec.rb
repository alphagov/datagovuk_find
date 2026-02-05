require "rake"
require "rails_helper"

RSpec.describe "Markdown to Static HTML Rake Task", type: :task do
  before(:all) do
    Rake.application.rake_require("tasks/markdown_to_static_html")
    Rake::Task.define_task(:environment)
  end

  let(:task) { Rake::Task["markdown:parse"] }
  let(:output_directory) { Rails.configuration.x.markdown_output_location }

  before do
    FileUtils.mkdir_p(output_directory)
  end

  it "parses markdown files and generates HTML/ERB files" do
    task.reenable
    task.invoke
    generated_files = Dir.glob(File.join(output_directory, "sample-collection", "*.html.erb"))
    expect(generated_files).not_to be_empty

    generated_files.each do |file|
      content = File.read(file)
      expect(content).to include("<h2")
    end
  end

  context "when markdown files are missing the collection in the front matter" do
    it "skips those markdown files" do
      task.reenable
      expect { task.invoke }.to output(/Skipping markdown file/).to_stdout
    end
  end

  after do
    FileUtils.rm_rf(Rails.root.join(Rails.configuration.x.markdown_output_location)) if Dir.exist?(Rails.root.join(Rails.configuration.x.markdown_output_location))
  end
end
