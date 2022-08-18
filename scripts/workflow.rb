require 'restclient'
require 'date'
require 'json'
require 'optparse'

TX_HOST = '127.0.0.1:80'

# run with `bundle exec ruby workflow.rb [--option]`

class TranscriptReleaser

  QUIPS = ['Wow, neat. We ', 'Great news - we ','You are not going to believe this! We ', 'Good golly! We ', 'Holy cow! We ']

  def initialize(completed: false , all: false, release_guids_path: false)
    raise "`completed` and `all` cannot be set to the same value. completed: #{completed} | all: #{all}" if completed == all

    @right_now = DateTime.now
    @completed, @all, @release_guids_path = completed, all, release_guids_path
  end

  def release
    puts 'Oh wow!'
    puts "Lemme get this straight - you want to release some transcripts?"
    puts "Right now, at #{@right_now}?"

    release_needin_ids = if @completed
                          get_from_release_count_json
                        elsif @all
                          get_from_all_uids_json
                        elsif @release_guids_path
                          File.read(@release_guids_path).split("\n")
                        end

    puts "Now we're going to write those release guids (#{ release_needin_ids.count }) to a file..."
    create_guid_file(release_needin_ids)

    filename = nil
    release_needin_ids.each do |guid|
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
      puts "OTHER WISE I WOULD RUN HERE #{filename}"
      #puts `./shellScriptToDuplicateAndPushNewFilesToS3.sh #{filename}`
      puts "Deleting file: #{filename}"
      File.delete(filename)
    end

    set_released_flag_for_completed_transcripts(release_needin_ids) if @completed

    puts 'Ah... That is the stuff.'
  end

  private

  def create_guid_file(guids)
    # write guids to file
    File.open("ready_for_release_guids_#{ @right_now }.txt", "w+") do |f|
      guids.each do |guid|
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

  def get_from_all_uids_json
    puts "Alright, first we're going to have to ask #{TX_HOST} for all the Transcript IDs..."
    response = RestClient.get(TX_HOST + '/all_uids.json')
    raise 'Didnt get a response for all_uids...' unless response.body
    JSON.parse(response.body)['data']
  end

  def set_released_flag_for_completed_transcripts(guids)
    guids.each do |id|
      puts "Updating the released flag on: #{id}"
      RestClient.patch(TX_HOST + '/transcripts/' + id, { 'released' => true } )
    end
  end
end

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: example.rb [options]"
  opts.on("-c", "--complete", "Release completed, but unreleased, transcripts to S3") do |c|
    options[:completed] = c
  end
  opts.on("-a", "--all", "Release ALL the transcripts to S3 with blatant disregard for completeness") do |a|
    options[:all] = a
  end
  opts.on("-i", "--id-file", "Release transcripts based on guids in a newline-delimited text file") do |a|
    if File.exist?(ARGV[0])
      options[:release_guids_path] = ARGV[0]
    else
      raise "No id file was found at #{ARGV[0]}"
    end
  end
end.parse!

TranscriptReleaser.new(options).release
