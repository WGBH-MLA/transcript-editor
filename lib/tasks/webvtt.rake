require 'fileutils'
require 'webvtt'

namespace :webvtt do

  # Usage: rake webvtt:read['oral-history']
  desc "Parse WebVTT files"
  task :read, [:project_key] => :environment do |task, args|
    puts "Reading WebVTT files..."
    # Retrieve transcripts that have "webvtt" as its vendor and are empty
    transcripts = Transcript.getForDownloadByVendor('webvtt', args[:project_key])
    puts "Retrieved #{transcripts.length} transcripts from collections with webvtt as its vendor that are empty"

    transcripts.find_each do |transcript|

      # Check if transcript already exists in project directory
      transcript_file = Rails.root.join('project', args[:project_key], 'transcripts', 'webvtt', "#{transcript[:vendor_identifier]}")
      webvtt = nil
      if File.exist? transcript_file
        puts "Found transcript in project folder: #{transcript_file}"
        webvtt = read_webvtt(transcript_file)
      else
        # TODO: support remote URLs
      end

      # Parse the contents
      if webvtt.nil?
        puts "Couldn't read: #{transcript_file}."
      elsif !webvtt.nil?
        puts "Loading: #{transcript_file}."
        transcript.loadFromWebVTT(webvtt)
      end
    end
  end

  def read_webvtt(file)
    WebVTT.read(file)
  rescue NoMethodError
    nil
  end

end
