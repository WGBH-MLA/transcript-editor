require 'fileutils'
require 'json'

namespace :pua do

  # Usage: rake pua:create_collections['oral-history']
  desc "Create collections in Pop Up Archive"
  task :create_collections, [:project_key] => :environment do |task, args|
    collections = Collection.getForUploadByVendor('pop_up_archive', args[:project_key])

    # Init a Pop Up Archive client
    pua_client = Pua.new

    # Do a match against existing collection titles
    existing_collections = pua_client.getCollections
    existing_collection_titles = existing_collections.map{|c| c["title"]}

    collections.find_each do |collection|
      if existing_collection_titles.include? collection[:title]
        puts "Skipping #{collection[:title]} as title already exists"
      else
        collection = pua_client.createCollection(collection)
        puts "Created collection #{collection[:vendor_identifier]}"
      end
    end
  end

  # Usage: rake pua:download['oral-history']
  desc "Download new transcripts from Pop Up Archive"
  task :download, [:project_key] => :environment do |task, args|

    # Retrieve transcripts that have Pop Up Archive as its vendor and are empty
    transcripts = Transcript.getForDownloadByVendor('pop_up_archive', args[:project_key])
    puts "Retrieved #{transcripts.length} transcripts from collections with Pop Up Archive as its vendor that are empty"

    # Init a Pop Up Archive client
    pua_client = Pua.new

    transcripts.find_each do |transcript|

      # Check if transcript already exists in project directory
      transcript_file = Rails.root.join('project', args[:project_key], 'transcripts', 'pop_up_archive', "#{transcript[:vendor_identifier]}.json")
      contents = ""
      if File.exist? transcript_file
        puts "Found transcript in project folder: #{transcript_file}"
        file = File.read(transcript_file)
        contents = JSON.parse(file)

      # Otherwise retrieve it fresh from Pop Up Archive
      else
        contents = pua_client.getItem(transcript)
        puts "Retrieved #{contents["id"]} from Pop Up Archive"
      end

      # Parse the contents
      if contents.empty?
        puts "Warning: contents of #{contents["id"]} is empty"
      else
        transcript.loadFromHash(contents)
      end

    end

  end

  # Usage: rake pua:download_data['oral-history']
  desc "Download all available data from Pop Up Archive"
  task :download_data, [:project_key, :overwrite] => :environment do |task, args|
    args.with_defaults overwrite: false

    collections = Collection.getForDownloadByVendor('pop_up_archive', args[:project_key])

    # Init a Pop Up Archive client
    pua_client = Pua.new

    collections.each do |collection|
      pua_collection = pua_client.getCollection(collection)
      item_ids = pua_collection["item_ids"]
      puts "Found #{item_ids.length} items from collection #{collection[:title]}"
      item_ids.each do |item_id|
        # Check if transcript already exists in project directory
        transcript_file = Rails.root.join('project', args[:project_key], 'transcripts', 'pop_up_archive', "#{item_id}.json")

        unless File.exist? transcript_file || args[:overwrite]
          contents = pua_client.getItemByIds(collection[:vendor_identifier], item_id)

          unless contents.empty?
            File.open(transcript_file,"w") do |f|
              f.write(contents.to_json)
              puts "Downloaded: #{transcript_file}"
            end
          end
        end

      end
    end

  end

  # Usage: rake pua:find_identifiers['oral-history','uid','title']
  desc "Try to find the Pop Up Archive item for transcripts without vendor identifiers"
  task :find_identifiers, [:project_key, :internal_key, :vendor_key] => :environment do |task, args|

    # Retrieve transcripts that have Pop Up Archive as its vendor and are empty
    transcripts = Transcript.getForUploadByVendor('pop_up_archive', args[:project_key])
    puts "Retrieved #{transcripts.length} transcripts from collections with Pop Up Archive as its vendor that are empty"

    collections = Collection.getForDownloadByVendor('pop_up_archive', args[:project_key])

    # Init a Pop Up Archive client
    pua_client = Pua.new
    # Retrieve Pop Up transcripts
    pua_transcripts = []
    collections.each do |collection|
      pua_collection = pua_client.getCollection(collection)
      item_ids = pua_collection["item_ids"]
      puts "Found #{item_ids.length} items from collection #{collection[:title]}"
      item_ids.each do |item_id|

        # Check if transcript already exists in project directory
        transcript_file = Rails.root.join('project', args[:project_key], 'transcripts', 'pop_up_archive', "#{item_id}.json")
        contents = ""

        if File.exist? transcript_file
          file = File.read(transcript_file)
          contents = JSON.parse(file)
        else
          contents = pua_client.getItemByIds(collection[:vendor_identifier], item_id)
        end

        unless contents.empty?
          pua_transcripts << contents
        end

      end
    end

    transcripts.find_each do |transcript|
      matches = pua_transcripts.select { |t| transcript[args[:internal_key]].strip == t[args[:vendor_key]].to_s.strip }
      if matches.length > 1
        puts "Multiple matches found for #{transcript[:uid]}"

      elsif matches.length <= 0
        puts "No matches found for #{transcript[:uid]}"

      else
        puts "Matches found for #{transcript[:uid]}!"
        match = matches[0]
        transcript.update(vendor_identifier: match["id"].to_s)
      end
    end

  end

  # Usage: rake pua:list_collections
  desc "List collections in Pop Up Archive"
  task :list_collections => :environment do |task, args|
    # Init a Pop Up Archive client
    pua_client = Pua.new

    collections = pua_client.getCollections

    collections.each do |collection|
      puts "ID: #{collection["id"]}, TITLE: #{collection["title"]}, COUNT: #{collection["number_of_items"]}"
    end
  end

  # Usage: rake pua:list_items['oral-history']
  desc "List items in Pop Up Archive"
  task :list_items, [:project_key]  => :environment do |task, args|

    collections = Collection.getForDownloadByVendor('pop_up_archive', args[:project_key])

    # Init a Pop Up Archive client
    pua_client = Pua.new
    # Retrieve Pop Up transcripts
    pua_transcripts = []
    collections.each do |collection|
      pua_collection = pua_client.getCollection(collection)
      item_ids = pua_collection["item_ids"]
      puts "Found #{item_ids.length} items from collection #{collection[:title]}"
      item_ids.each do |item_id|

        # Check if transcript already exists in project directory
        transcript_file = Rails.root.join('project', args[:project_key], 'transcripts', 'pop_up_archive', "#{item_id}.json")
        contents = ""

        if File.exist? transcript_file
          file = File.read(transcript_file)
          contents = JSON.parse(file)
        else
          contents = pua_client.getItemByIds(collection[:vendor_identifier], item_id)
        end

        puts "#{contents["id"]} - #{contents["title"]}" unless contents.empty?

      end
    end
  end

  # Usage: rake pua:upload['oral-history']
  desc "Upload the unprocessed audio to Pop Up Archive"
  task :upload, [:project_key] => :environment do |task, args|

    # Retrieve transcripts that have Pop Up Archive as its vendor and are empty
    transcripts = Transcript.getForUploadByVendor('pop_up_archive', args[:project_key])
    puts "Retrieved #{transcripts.length} transcripts from collections with Pop Up Archive as its vendor that are empty"

    # Init a Pop Up Archive client
    pua_client = Pua.new

    transcripts.find_each do |transcript|
      item = pua_client.createItem(transcript)
    end

  end

  # Usage: rake pua:update['oral-history']
  desc "Update metadata from Pop Up Archive"
  task :update, [:project_key] => :environment do |task, args|
    # Retrieve transcripts that have Pop Up Archive as its vendor and are empty
    transcripts = Transcript.getForUpdateByVendor('pop_up_archive', args[:project_key])
    puts "Retrieved #{transcripts.length} transcripts from collections with Pop Up Archive as its vendor that are empty"

    # Init a Pop Up Archive client
    pua_client = Pua.new

    transcripts.find_each do |transcript|

      # Check if transcript already exists in project directory
      transcript_file = Rails.root.join('project', args[:project_key], 'transcripts', 'pop_up_archive', "#{transcript[:vendor_identifier]}.json")
      contents = ""
      if File.exist? transcript_file
        puts "Found transcript in project folder: #{transcript_file}"
        file = File.read(transcript_file)
        contents = JSON.parse(file)

      # Otherwise retrieve it fresh from Pop Up Archive
      else
        contents = pua_client.getItem(transcript)
        puts "Retrieved #{contents["id"]} from Pop Up Archive"
      end

      # Parse the contents
      unless contents.empty?
        transcript.updateFromHash(contents)
      end

    end
  end

end
