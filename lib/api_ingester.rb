require 'webvtt'
WEBVTT_FOLDER = "#{Rails.root}/project/#{ ENV["PROJECT_ID"] }/transcripts/webvtt/"
require 'transcript_converter/reader/json_file'
require 'transcript_converter/converter/webvtt_file'

class APIIngester
  include TranscriptConverter::Reader
  def initialize(list, options={})
    raise "No list provided!" unless list && list.class == Array

    `mkdir -p "#{Rails.root}/project/#{ENV["PROJECT_ID"]}/transcripts/webvtt"`

    @options = options

    @errors = {}
    @list = clean_list(list)
    @records = []
    @errored_records = []

    @create_missing_collections = options[:create_missing_collections]
  end

  def options
    @options
  end

  def records
    @records
  end

  def errors
    # transform into records: [error, error, error]
    er = {}
    @errored_records.each do |aapb_record|
      er[aapb_record.uid] = aapb_record.errors
    end

    er
  end

  def clean_list(list)
    list.map {|guid| guid.gsub(/\s/, "") }
  end

  def run!
    create_aapb_records(@list)
    create_collections(@records) if @create_missing_collections
    initialize_transcripts(@records)
    convert_transcripts(@records)
    ingest_transcripts(@records)
  end

  def create_aapb_records(list)
    @records, @errored_records = list.map {|guid| AAPBRecord.new(guid, options)}.partition {|aapbr| aapbr.errors.empty? }
  end

  def create_collections(records)
    records.each do |aapb_record|
      unless aapb_record.collection
        Collection.create(uid: aapb_record.organization_pbcore_name, title: aapb_record.organization_pbcore_name, vendor_id: 0, project_uid: ENV["PROJECT_ID"])
        puts "Created missing collection #{aapb_record.organization_pbcore_name} ya heard!"
      end
    end
  end

  def initialize_transcripts(records)
    puts "Initializing transcripts..."
    records.each do |aapb_record|
      puts "Initializing #{aapb_record.uid    }"
      initialize_transcript(aapb_record.uid, aapb_record.collection.id, aapb_record.title, aapb_record.description, aapb_record.aapb_url, aapb_record.audio_url, aapb_record.image_url)
    end

    puts "Wrote #{records.count} Transcripts to database..."
  end

  def initialize_transcript(uid, collection_id, title, description, aapb_url, audio_url, image_url)
    params = {
      uid: uid,
      collection_id: collection_id,
      project_uid: ENV["PROJECT_ID"],

      # webvtt vendor, the  only one we use
      vendor_id: 2,
      vendor_identifier: "#{uid}.vtt",
      batch_id: %(#{Date.today}-ingest),

      title: title,
      description: description,
      url: aapb_url,
      audio_url: audio_url,
      image_url: image_url,
      # notes: ,

    }

    # the force_reingest option prevents this line from overwriting data from an existing ts by erroring before this
    ts = Transcript.find_or_initialize_by(uid: uid)
    ts.update(params)
    # Transcript.create(params)
  end

  def convert_transcripts(records)

    records.each do |record|
      # pump file object into the readah
      # puts "Reading input JSON file for #{record.uid}"
      # content = TranscriptConverter::Reader::JSONFile.new(record.transcript_file).run!
      
      json_transcript = format_json_content(record.uid, record.transcript_data)
      # this writes to files in the speced folder because i dont feel like rewriting the TranscriptConverter
      puts "Converting JSON to WebVTT file for #{record.uid}..."
      TranscriptConverter::Converter::WebVTTFile.new(json_transcript, WEBVTT_FOLDER).run!
    end
  end
  def ingest_transcripts(records)
    guids = records.map(&:uid)
    transcripts = Transcript.where(uid: guids).all
    transcripts.each do |transcript|
      webvtt_content = read_webvtt("#{WEBVTT_FOLDER}/#{transcript.uid}.vtt")
      puts "Loading in #{transcript.uid} from webvtt file..."
      transcript.loadFromWebVTT(webvtt_content)
    end
  end
  
  def read_webvtt(file)
    WebVTT.read(file)
  rescue NoMethodError
    nil
  end


  def format_json_content(uid, json_data)
    { "file_name" => uid, "parts" => json_data["parts"] }
  end
end

