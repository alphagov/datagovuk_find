require 'private_beta_user' 

namespace :user do
  desc 'Create a new beta user'
  task :generate, [:username] => :environment do |t, args|
    puts PrivateBetaUser.generate(args[:username])
  end
end
