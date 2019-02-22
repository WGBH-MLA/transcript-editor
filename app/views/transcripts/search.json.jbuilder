json.entries @transcripts do |transcript|
  json.extract! transcript, :uid, :title, :description, :image_url, :collection_id, :collection_title, :duration, :lines_edited, :percent_completed, :percent_edited, :percent_reviewing, :users_contributed
  if @project_settings["useVendorAudio"]
    json.audio_urls transcript[:vendor_audio_urls]
  else
    json.audio_urls [transcript[:audio_url]]
  end
  json.path transcript_path(transcript)
end

json.current_page @transcripts.current_page
json.per_page @transcripts.per_page
json.total_entries @transcripts.total_entries
