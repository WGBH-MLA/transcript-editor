require_relative "../config/environment"

puts "Hello! It me - #{Rails.env} - #{Rails.configuration.database_configuration[ Rails.env ]}"

# Transcript.all.each do |tran|
#   puts "Checking #{train.uid}..."
#   if tran.audio_url.start_with?("https://americanarchive.org")
#     puts "Found old, changing #{train.uid}"
#     tran.audio_url = tran.audio_url.gsub("https://americanarchive.org", "")
#     tran.save
#   end
# end
