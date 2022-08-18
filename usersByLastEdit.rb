require_relative "config/environment"

File.open("reportUsersByLastEdit.csv", "w+") do |f|
  f << %(User ID, User Email, Last Edit Date, Last Edit Transcript UID,Last Edit Transcript Text\n)
  User.all.each do |user|

    newest_edit = TranscriptEdit.where(user_id: user.id).order(updated_at: :desc).first
    if newest_edit
      f << %(#{user.id},#{user.email},#{newest_edit.updated_at},#{newest_edit.transcript ? newest_edit.transcript.uid : "Transcript Deleted"},"#{newest_edit.text}"\n)
    else
      f << %(#{user.id},#{user.email},-,-,-\n)
    end
  end
end
