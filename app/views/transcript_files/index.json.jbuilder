json.entries @transcripts do |transcript|
  json.id transcript[:uid]
  json.collection_id transcript[:collection_uid]
  json.extract! transcript, :title, :updated_at
  json.files do
    json.json transcript_file_url(transcript, format: :json)
    json.vtt transcript_file_url(transcript, format: :vtt)
    json.text transcript_file_url(transcript, format: :text)
    json.aapb aapb_transcript_url(transcript, format: :json)
  end
end

json.current_page @transcripts.current_page
json.per_page @transcripts.per_page
json.total_entries @transcripts.total_entries
