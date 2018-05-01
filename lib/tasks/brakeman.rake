desc "Run Brakeman"
task :brakeman do
  sh 'brakeman -w2 -q'
end
