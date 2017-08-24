require 'private_beta_user' 

namespace :user do
  task :generate, [:username] => :environment do |t, args|
    puts PrivateBetaUser.generate(args[:username])
  end
end
