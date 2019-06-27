require 'test_helper'
require 'nokogiri'

class AAPBRecordTest < ActiveSupport::TestCase

  slash_guid = 'cpb-aacip/301-00000079'
  underscore_guid = 'cpb-aacip_301-00000079'
  aapb_record = AAPBRecord.new(slash_guid)

  test "#initialize do" do
    assert AAPBRecord.new(slash_guid).uid == underscore_guid
    assert AAPBRecord.new(underscore_guid).uid == underscore_guid
  end

  test "#pbcore_url" do
    assert aapb_record.pbcore_url == 'https://americanarchive.org/catalog/cpb-aacip_301-00000079.pbcore'
  end

  test "#pbcore_doc" do
    assert !aapb_record.pbcore.nil?
  end

  test "#titles" do
    assert aapb_record.titles == [["Series", "Hit the Dirt"], ["Episode", "Winter Protection"]]
  end

  test "#title" do
    assert aapb_record.title == "Hit the Dirt; Winter Protection"
  end

  test "#description" do
    assert aapb_record.description == "Hit the Dirt is an educational show providing information about a specific\naspect of gardening each episode."
  end

  test "#aapb_url" do
    assert aapb_record.aapb_url == "https://americanarchive.org/catalog/cpb-aacip_301-00000079"
  end

  test "#audio_url" do
    assert aapb_record.audio_url == "https://americanarchive.org/media/cpb-aacip_301-00000079?part=1"
  end

  test "#image_url" do
    assert aapb_record.image_url == "https://americanarchive.org/thumbs/audio-digitized.jpg"
  end

  test "#transcript_url" do
    assert aapb_record.transcript_url == "https://s3.amazonaws.com/americanarchive.org/transcripts/cpb-aacip-301-00000079/cpb-aacip-301-00000079-transcript.json"
  end

  test "#organization_pb_core_name" do
    assert aapb_record.organization_pb_core_name == "WERU-FM (WERU Community Radio)"
  end
end
