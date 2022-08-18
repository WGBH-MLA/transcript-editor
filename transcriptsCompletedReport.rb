require_relative "config/environment"

File.open("reporto.csv", "w+") do |f|
  Transcript.where("percent_completed >= 99").all.each do |transcript|
    transcript_completed_at = transcript.transcript_lines.order(updated_at: :desc).first.updated_at
    puts "I found that tran #{transcript.uid} was completed at #{transcript_completed_at}"
    f << %(#{transcript.uid},#{transcript_completed_at}\n)
  end
end
