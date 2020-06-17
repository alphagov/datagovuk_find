desc "Run Brakeman"
task brakeman: :environment do
  sh "brakeman -w2 -q"
end
