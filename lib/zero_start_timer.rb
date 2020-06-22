class ZeroStartTimer

  attr_reader :transcripts

  def initialize(guids_file)
    raise "Not a valid ids_file_path: #{guids_file}" unless File.exist?(guids_file)
    guids = build_guids_array(guids_file)
    @transcripts = guids.map{ |id| Transcript.find_by(uid: id) }
  end

  def run!
    make_zero
  end

  private

  def make_zero
    lines = []
    transcripts.each do |transcript|
      transcript_line = transcript.transcript_lines.sort_by(&:sequence).first
      transcript_line.start_time = 0
      lines << transcript_line
    end

    TranscriptLine.transaction do
      lines.each(&:save!)
    end
  end

  def build_guids_array(file_path)
    File.readlines(file_path).map { |id| id.tr("\n","").gsub('cpb-aacip/', 'cpb-aacip_') }
  end

end