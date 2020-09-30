require 'restclient'
require 'date'
require 'json'

TX_HOST = '127.0.0.1:80'

# run with `sudo ruby scripts/workflow.rb`

class TranscriptReleaser

  REGISTERED_MODES = [ "ALL", "COMPLETED" ]
  QUIPS = ['Wow, neat. We ', 'Great news - we ','You are not going to believe this! We ', 'Good golly! We ']

  def initialize(argv)
    @mode = argv.shift.gsub("--","").upcase
    raise "Unrecognized release mode. Must be set to --completed or --all on script init." unless REGISTERED_MODES.include?(@mode)

    @right_now = DateTime.now
    @release_needin_ids = if @mode == "COMPLETED"
                            get_from_release_count_json
                          elsif @mode == "ALL"
                            puts "Alright, we're going to get all them transcript IDs..."
                            Transcript.all.map(&:uid)
                          end
  end

  def create_guid_file
    # write guids to file
    puts "Now we're going to write those release guids (#{ @release_needin_ids.count }) to a file..."

    File.open("ready_for_release_guids_#{ @right_now }.txt", "w+") do |f|
      @release_needin_ids.each do |guid|
        f << guid + "\n"
      end
    end
  end

  def get_from_release_count_json
    puts "Alright, first we're going to have to ask #{TX_HOST} which ones are ready to release..."
    response = RestClient.get(TX_HOST + '/release_count.json')
    raise 'Didnt get a response for release_count...' unless response.body
    JSON.parse(response.body)['data']
  end

  def set_released_flag_for_completed_transcripts
    @release_needin_ids.each do |id|
      puts "Updating the released flag on: #{id}"
      RestClient.patch(TX_HOST + '/transcripts/' + id, { 'released' => true } )
    end
  end

  def release
    puts 'Oh wow!'
    puts "Lemme get this straight - you want to release some transcripts?"
    puts "Right now, at #{@right_now}?"

    create_guid_file

    filename = nil
    @release_needin_ids.each do |guid|
      transcript_json = RestClient.get(TX_HOST + "/transcripts/aapb/#{ guid }.json")
      # filename = "transcript-#{ right_now }-#{guid}.json"
      filename = "#{guid.gsub('_','-')}-transcript.json"
      File.open(%(./transcript-json/#{filename}), 'w+') do |f|
        f << transcript_json
        puts QUIPS.sample + " wrote #{guid} data to #{filename}."
      end
    end

    puts "Well, that was fun. Now we've got all the files we need."

    Dir.glob(__dir__ + "/transcript-json/*.json").each do |filename|
      puts `./shellScriptToDuplicateAndPushNewFilesToS3.sh #{filename}`
      puts "Deleting file: #{filename}"
      File.delete(filename)
    end

    set_released_flag_for_completed_transcripts if @mode == 'ALL'
    puts 'Ah... That is the stuff.'
  end
end

# TranscriptReleaser.new(ARGV)
