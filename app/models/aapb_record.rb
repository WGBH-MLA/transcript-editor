require 'open-uri'
require "#{Rails.root}/lib/html_scrubber"

class AAPBRecord
  attr_reader :uid, :pbcore_url, :pbcore, :title, :description, :aapb_url, :audio_url, :image_url, :transcript_url

  MOVING_IMAGE = 'Moving Image'.freeze
  SOUND = 'Sound'.freeze
  OTHER = 'other'.freeze
  S3_BASE = 'https://s3.amazonaws.com/americanarchive.org'.freeze

  def initialize(uid, options={})
    @uid = process_uid(uid)
    @errors = []
    @options = options
    @create_missing_collections = @options[:create_missing_collections]
    validate
  end

  def validate
    if Transcript.where(uid: uid).first && !@options[:force_reingest]
      @errors << "#{uid} already exists in Fixit database!"
    end

    # fetches from aapb 
    pbcore if errors.empty?
    # grab vals from xml and validate alloooong the way
    transcript_url if errors.empty?

    organization_pbcore_name if errors.empty?

    transcript_data if errors.empty?

    collection if errors.empty?
  end

  def errors
    @errors ||= []
  end

  def aapb_url
    @aapb_url ||= "https://americanarchive.org/catalog/#{uid}"
  end

  def audio_url
    @audio_url ||= media_srcs.first
  end

  def pbcore_url
    @pbcore_url ||= "https://americanarchive.org/catalog/#{uid}.pbcore"
  end

  def pbcore
    @pbcore ||= REXML::Document.new(open(pbcore_url).read)
  rescue OpenURI::HTTPError => e
    @errors << "PBCore file was not accessible!"
  end

  def titles
    @titles ||= pairs_by_type('/*/pbcoreTitle', '@titleType')
  end

  def title
    @title ||= titles.map(&:last).join('; ')
  end

  def description
    @description ||= xpaths('/*/pbcoreDescription').map { |desc| HtmlScrubber.scrub(desc) }.join(' ')
  end

  def collection
    @collection ||= begin
      collection = Collection.where(uid: organization_pbcore_name).first
      unless collection || @create_missing_collections
        # dont record error if 'allow empty', because we will create missing collections in the next step
        @errors << "Found no matching collection #{organization_pbcore_name} for record #{uid}!"
      end
      
      collection
    end
  end

  def image_url
    @image_url ||=
      case media_type
      when MOVING_IMAGE
        "#{S3_BASE}/thumbnail/#{uid}.jpg"
      when SOUND
        'https://americanarchive.org/thumbs/audio-digitized.jpg'
      else
        'https://americanarchive.org/thumbs/other.jpg'
      end
  end

  def transcript_url
    @transcript_url ||= xpath("/*/pbcoreAnnotation[@annotationType='Transcript URL']")
  rescue NoMatchError
    errors << "#{uid} does not have Transcript URL annotation!"
    nil
  end

  def get_transcript_data(url)
    URI.open(url).read
  end

  def transcript_data
    @transcript ||= begin
      content = get_transcript_data(transcript_url)

      if !content.empty?
        begin
          # gets parsed again in the JSONFile 'reader' class, but do it here to validate
          json = JSON.parse(content)

          unless json['parts']
            @errors << "Transcript json did not have 'parts' key - invalid transcript format!"
          end
        rescue JSON::ParserError
          @errors << "Transcript file had invalid JSON!"
        end

      else
        @errors << "Transcript file was empty!"
      end

      json
    rescue OpenURI::HTTPError => e
      @errors << "Transcript file was not accessible! #{e}"
    end

  end

  def organization_pbcore_name
    # TODO: switch to organ uid service
    @organization_pbcore_name ||= xpath('/*/pbcoreAnnotation[@annotationType="organization"]')
  rescue NoMatchError
    errors << "#{uid} does not have a pbcoreAnnotation type='organization'!"
  end

  private

  def process_uid(input_uid)
    raise "Unexpected AAPB GUID format" unless input_uid =~ /^cpb-aacip(\/|_|-).*/
    input_uid = input_uid.delete(" ")
    input_uid.include?("\/") ? input_uid.tr("\/", '_') : input_uid
  end

  def xpath(xpath)
    REXML::XPath.match(pbcore, xpath).tap do |matches|
      if matches.length != 1
        raise NoMatchError, "Expected 1 match for '#{xpath}'; got #{matches.length}"
      else
        return text_from(matches.first)
      end
    end
  end

  def xpaths(xpath)
    REXML::XPath.match(pbcore, xpath).map { |node| text_from(node) }
  end

  def text_from(node)
    ((node.respond_to?('text') ? node.text : node.value) || '').strip
  end

  def pairs_by_type(element_xpath, attribute_xpath)
    REXML::XPath.match(pbcore, element_xpath).map do |node|
      key = REXML::XPath.first(node, attribute_xpath)
      [
        key ? key.value : nil,
        node.text
      ]
    end
  end

  def ci_ids
    @ci_ids ||= xpaths("/*/pbcoreIdentifier[@source='Sony Ci']")
  end

  def media_srcs
    @media_srcs ||= (1..ci_ids.count).map { |part| "/media/#{uid}?part=#{part}" }
  end

  def media_type
    @media_type ||= begin
      media_types = xpaths('/*/pbcoreInstantiation/instantiationMediaType')
      [MOVING_IMAGE, SOUND, OTHER].each do |type|
        return type if media_types.include? type
      end
      return OTHER if media_types == []
      # pbcoreInstantiation is not required, so this is possible
      raise "Unexpected media types: #{media_types.uniq}"
    end
  end

  class NoMatchError < StandardError
  end
end
