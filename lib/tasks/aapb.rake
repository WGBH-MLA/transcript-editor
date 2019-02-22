require 'fileutils'
require_relative '../aapb/transcript_seeds_job'
require_relative '../aapb/download_transcripts_job'
require_relative '../aapb/delete_transcripts_job'

namespace :aapb do
  # Usage rake aapb:create_seeds['ids_file_path','sample-project']
  desc "Generates a transcripts seeds CSV file from a file of AAPB guids"
  task :create_seeds, [:ids_file_path, :project_key] => :environment do |task, args|
    puts "Creating transcripts seeds CSV..."
    raise "Not a valid ids_file_path #{args[:ids_file_path]}" unless File.exist?(args[:ids_file_path])
    raise "Not a valid project_key" unless Dir.exist?(Rails.root.join('project', args[:project_key]))

    ids_file_path = args[:ids_file_path]
    project_key = args[:project_key]

    ids = build_ids_array(ids_file_path)
    AAPB::TranscriptSeedsJob.new(ids,project_key).run!
  end

  # Usage rake aapb:download_transcripts['ids_file_path','sample-project']
  desc "Downloads transcripts specified in AAPBRecords to an aapb directory in a project's transcript directory"
  task :download_transcripts, [:ids_file_path, :project_key] => :environment do |task, args|
    puts "Downloading transcripts..."
    raise "Not a valid ids_file_path #{args[:ids_file_path]}" unless File.exist?(args[:ids_file_path])
    raise "Not a valid project_key" unless Dir.exist?(Rails.root.join('project', args[:project_key]))

    ids = build_ids_array(args[:ids_file_path])
    AAPB::DownloadTranscriptsJob.new(ids,args[:project_key]).run!
  end

  desc "Ingests transcripts from a file of AAPB GUIDs"
  task :ingest_guids, [:ids_file_path, :project_key] => :environment do |task, args|
    raise "Not a valid ids_file_path #{args[:ids_file_path]}" unless File.exist?(args[:ids_file_path])
    raise "Not a valid project_key" unless Dir.exist?(Rails.root.join('project', args[:project_key]))
    raise "No Collections currently defined for #{args[:project_key]}" unless Collection.where(project_uid: args[:project_key]).count > 0

    Rake::Task["aapb:create_seeds"].invoke("#{args[:ids_file_path]}","#{args[:project_key]}")
    Rake::Task["transcripts:load"].invoke("#{args[:project_key]}","#{Date.today}.csv")
    Rake::Task["aapb:download_transcripts"].invoke("#{args[:ids_file_path]}","#{args[:project_key]}")
    Rake::Task["transcripts:convert"].invoke("#{Rails.root}/project/#{args[:project_key]}/transcripts/aapb","#{Rails.root}/project/#{args[:project_key]}/transcripts/webvtt","vtt")
    Rake::Task["webvtt:read"].invoke("#{args[:project_key]}")
  end

  desc "Deletes transcripts from a file of AAPB GUIDS"
  task :delete_guids, [:ids_file_path] => :environment do |task,args|
    raise "Not a valid ids_file_path #{args[:ids_file_path]}" unless File.exist?(args[:ids_file_path])

    ids = build_ids_array(args[:ids_file_path])
    AAPB::DeleteTranscriptsJob.new(ids).run!
  end

  def build_ids_array(file_path)
    File.readlines(file_path).map { |id| id.tr("\n","") }
  end
end
