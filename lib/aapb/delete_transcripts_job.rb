require 'open-uri'

module AAPB
  class DeleteTranscriptsJob
    attr_reader :uids

    def initialize(uids)
      raise "DeleteTranscriptsJob must be initialized with an Array of uids." unless uids.is_a?(Array)
      @uids = uids
    end

    def run!
      delete_transcripts
    end

    private

    def delete_transcripts
      uids.each do |uid|
        transcript = Transcript.find_by_uid(uid)
        if !transcript.nil?
          puts "Deleting transcript: #{uid}"
          transcript.delete
        else
          puts "Transcript not found: #{uid}"
        end
      end
    end
  end
end
