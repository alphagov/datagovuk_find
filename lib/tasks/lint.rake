desc "Run rubocop on all files"
task "lint" do
  sh "bundle exec rubocop --parallel app lib spec test --format clang"
end
