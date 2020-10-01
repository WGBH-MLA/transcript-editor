json.language "en-US"
json.id @transcript.uid
json.percent_completed @transcript.percent_completed

lines = @transcript.transcript_lines.each do |line|
  line.start_time /= 1000
  line.end_time /= 1000
  line.text = line.best_text
end

json.parts lines, :id, :start_time, :end_time, :text