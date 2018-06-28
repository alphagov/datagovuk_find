#!/usr/local/bin/ruby -w
require 'json'

app = ARGV[0]
key = ARGV[1]
value = ARGV[2]

puts "Reading env from '#{app}'..."
app_env = `cf env #{app}`

sys_env = app_env.split('System-Provided:').last.split("{\n \"VCAP_APP").first.delete("\n")
sys_env = JSON.parse(sys_env)

puts "Got application env, detecting credentials service name..."
secret_service = sys_env["VCAP_SERVICES"]["user-provided"].select { |s| s["name"].include?("secret") }.first

puts "Using secrets service '#{secret_service['name']}'"
puts "\nWARNING! This is a potentially destructive operation!"
puts "Do you wish to continue changing #{key} on #{secret_service['name']}? [yN]"
unless %w(y yes).include?(STDIN.gets.chomp.downcase)
  puts "Aborting"
  exit
end

puts "\nSetting credential #{key} to #{value} on #{secret_service['name']}..."

creds = secret_service["credentials"]
creds[key] = value

creds_dump = JSON.dump(creds)
`cf uups #{secret_service["name"]} -p '#{creds_dump}'`
