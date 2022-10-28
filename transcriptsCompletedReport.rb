require_relative "config/environment"

File.open("reporto.csv", "w+") do |f|
  f << %(GUID,Percentage Complete,Completion Date\n)
  Transcript.all.each do |transcript|
    if transcript.percent_completed >= 99
      transcript_completed_at = transcript.transcript_lines.order(updated_at: :desc).first.updated_at
      puts "I found that tran #{transcript.uid} was completed at #{transcript_completed_at}"
    else
      puts "OOF tran #{transcript.uid} was not completed, but its #{transcript.percent_completed} percent complete"
      transcript_completed_at = "-"
    end
    f << %(#{transcript.uid},#{transcript.percent_completed},#{transcript_completed_at}\n)
  end
end
