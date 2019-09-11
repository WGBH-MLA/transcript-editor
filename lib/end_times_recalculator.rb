class EndTimesRecalculator

  attr_reader :transcripts

  def initialize(guids_file)
    raise "Not a valid ids_file_path: #{guids_file}" unless File.exist?(guids_file)
    guids = build_guids_array(guids_file)
    @transcripts = guids.map{ |id| Transcript.find_by(uid: id) }
  end

  def run
    recalculate
  end

  private

  def recalculate
    transcripts.each do |transcript|
      lines = []
      transcript_lines = transcript.transcript_lines.sort_by(&:sequence)
      transcript_lines.each_with_index do |line, i|
        # use the next transcript_line's start_time for end_time unless it's the last transcript_line
        unless line == transcript_lines[-1]
          new_end_time = (transcript_lines[i + 1].start_time / 1000).to_f - 0.01
          line.end_time = (new_end_time * 1000).to_i
          lines << line
        end
      end

      TranscriptLine.transaction do
        lines.each(&:save!)
      end
    end
  end

  def build_guids_array(file_path)
    File.readlines(file_path).map { |id| id.tr("\n","").gsub('cpb-aacip/', 'cpb-aacip_') }
  end

end