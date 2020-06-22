require_relative '../end_times_recalculator'
require_relative '../zero_start_timer'

namespace :transcript_lines do

  # Usage:
  #     rake transcript_lines:recalculate[0,0,1]
  #     rake transcript_lines:recalculate[0,'adrian-wagner-nxr3fk']
  #     rake transcript_lines:recalculate[56]
  #     rake transcript_lines:recalculate
  desc "Recalculate a line, a transcript's lines, or all lines"
  task :recalculate, [:line_id, :transcript_uid, :original_text] => :environment do |task, args|
    args.with_defaults line_id: 0
    args.with_defaults transcript_uid: false
    args.with_defaults original_text: false

    lines = []
    line_id = args[:line_id].to_i

    if line_id > 0
      lines = TranscriptLine.where(id: line_id)

    elsif !args[:original_text].blank?
      lines = TranscriptLine.where("text = original_text")

    elsif !args[:transcript_uid].blank?
      transcript = Transcript.find_by(uid: args[:transcript_uid])
      lines = TranscriptLine.getEditedByTranscriptId(transcript.id)

    else
      lines = TranscriptLine.getEdited
    end

    lines.each do |line|
      line.recalculate
    end

  end

  # rake transcript_lines:find_max_overlap
  task :find_max_overlap => :environment do |task, args|

    transcripts = Transcript.where('lines > 0')
    overlap_max = 0
    transcript_max = nil

    transcripts.each do |transcript|
      lines = TranscriptLine.where(transcript_id: transcript.id)
      previous_line = nil
      overlaps = []
      lines.each do |line|
        if previous_line
          overlap = previous_line.end_time - line.start_time
          overlaps << overlap
        end
        previous_line = line
      end
      if overlaps.length > 0
        sum = overlaps.inject(0){|sum,x| sum + x }
        avg = sum / overlaps.length
        if avg > overlap_max
          overlap_max = avg
          transcript_max = transcript
        end
      end
    end

    if transcript_max
      puts "Max transcript overlap: #{transcript_max.uid} #{transcript_max.title} (#{overlap_max})"
    end

  end

  # Usage rake transcript_lines:recalculate_end_times['transcript_ids_file_path']
  desc "Sets TranscriptLine end_times to be the start_times of the subsequent TranscriptLine"
  task :recalculate_end_times, [:path] => :environment do |task, args|
    puts "Recalculating end_times..."
    raise "Not a valid file: #{args[:path]}" unless File.exist?(args[:path])

    EndTimesRecalculator.new(args[:path]).run!
  end


  # Usage rake transcript_lines:zero_start_times['transcript_ids_file_path']
  desc "Sets the first TranscriptLine start_time to 0"
  task :zero_start_times, [:path] => :environment do |task, args|
    puts "Zero-ing start_times..."
    raise "Not a valid file: #{args[:path]}" unless File.exist?(args[:path])

    ZeroStartTimer.new(args[:path]).run!
  end

end
