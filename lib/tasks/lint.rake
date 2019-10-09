desc "Run govuk-lint on all files"
task "lint" do
  sh "bundle exec rubocop --parallel app config lib spec --format clang"
end
