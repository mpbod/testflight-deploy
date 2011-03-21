require 'rubygems'
require 'rest_client'
require 'scanf.rb'

END_POINT = "http://testflightapp.com/api/builds.json"
API_TOKEN = "API_TOKEN_GOES_HERE"
TEAM_TOKEN = "TEAM_TOKEN_GOES_HERE"
DIST_LIST = "DISTRIBUTION_LIST_NAMES_GOES_HERE" # Comma seperate the names.
notify = true;

if ARGV.size <= 1
  puts "\nusage: #{__FILE__} ipa_file release_note_file\n\n"
  exit(0)
end

ipa_file = ARGV[0]
release_note = IO.readlines(ARGV[1],'').join("\n")
puts "-" * 50
puts "|      Going to upload build to TestFlight!      |"
puts "-" * 50
puts "With IPA:\n#{ipa_file} (#{"%.2f" % (File.size(ipa_file) / 1000.0 / 1000.0)} MiB)\n\nWith Release Notes:\n#{release_note}"
puts "-" * 50

print "\n\nWould you like to notify the users (default is yes): "
input = scanf('%s')[0]
if input == "yes" || input == "YES"
  notify = true
else
  notify = false
end
puts "Notify User set to \"#{notify ? "Yes" : "No"}\"."


print "\n\nPlease confirm by entering \"FLY\": "
input = scanf('%s')[0]

if input != "FLY"
  puts "\n\nDeploy canceled."
  exit(0)
end

# Code from https://github.com/lukeredpath/betabuilder/blob/master/lib/beta_builder/deployment_strategies/testflight.rb
# Copyright (c) 2010 Luke Redpath

payload = {
          :api_token          => API_TOKEN,
          :team_token         => TEAM_TOKEN,
          :file               => File.new(ipa_file, 'rb'),
          :notes              => release_note,
          :distribution_lists => DIST_LIST,
          :notify             => notify
        }
        
puts "Uploading build to TestFlight..."

begin
  response = RestClient.post(END_POINT, payload, :accept => :json)
rescue => e
  response = e.response
end

if (response.code == 201) || (response.code == 200)
  puts "Upload complete."
else
  puts "Upload failed. (#{response})"
end