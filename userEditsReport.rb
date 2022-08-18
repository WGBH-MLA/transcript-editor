require_relative "config/environment"

File.open("userLinesReporto.csv", "w+") do |f|
  f << %(TS UID,Winner User ID,Winner Email,TS COMPLETION DATE,Num Anon Edits\n)

  Transcript.where("percent_completed >= 99").all.each do |transcript|

    most_edits_user = nil
    transcript_completed_at = transcript.transcript_lines.order(updated_at: :desc).first.updated_at

    # skipp until we get to 2021
    # next unless transcript_completed_at.year > 2020
    next unless transcript.transcript_edits.count > 0

    edits_by_user = transcript.transcript_edits.group_by {|tl| tl.user_id }

    num_edits_by_user = {}
    most_edits_user_id = -1
    edits_by_user.each do |user_id, edits|

      num_edits_by_user[user_id] = edits.count

      # not anon, eitheir initial run or has more edits than previous winner
      puts "NOW IM CHECKING USER ID #{user_id}"
      if user_id != 0 && (most_edits_user_id == -1 || edits.count > edits_by_user[most_edits_user_id].count)
        # collect 
        most_edits_user_id = user_id
        puts "Most edits user id is !!! #{most_edits_user_id} #{}"
      end
    end
    
    most_edits_user = User.find(most_edits_user_id) if most_edits_user_id != -1
    if most_edits_user
      most_edits_user_email = most_edits_user.email
    else
      most_edits_user_email = "None"
    end

    puts "#{transcript.uid} ::: WINNER #{most_edits_user_email}"

    f << %(#{transcript.uid},#{most_edits_user_id},#{most_edits_user_email},#{transcript_completed_at},#{num_edits_by_user[0]}\n)
  end
end
