require 'open-uri'
require_relative '../../lib/html_scrubber'

class AAPBRecord
  attr_reader :uid, :pbcore_url, :pbcore, :title, :description, :aapb_url, :audio_url, :image_url, :transcript_url

  MOVING_IMAGE = 'Moving Image'.freeze
  SOUND = 'Sound'.freeze
  OTHER = 'other'.freeze
  S3_BASE = 'http://americanarchive.org.s3.amazonaws.com'.freeze

  def initialize(id)
    @uid = process_id(id)
  end

  def aapb_url
    @aapb_url ||= "http://americanarchive.org/catalog/#{uid}"
  end

  def audio_url
    @audio_url ||= media_srcs.first
  end

  def pbcore_url
    @pbcore_url ||= "http://americanarchive.org/catalog/#{uid}.pbcore"
  end

  def pbcore
    @pbcore ||= get_pbcore
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

  def image_url
    @image_url ||=
      case media_type
      when MOVING_IMAGE
        "#{AAPB::S3_BASE}/thumbnail/#{uid}.jpg"
      when SOUND
        'http://americanarchive.org/thumbs/audio-digitized.jpg'
      else
        'http://americanarchive.org/thumbs/other.jpg'
      end
  end

  def transcript_url
    @transcript_url ||= xpath("/*/pbcoreAnnotation[@annotationType='Transcript URL']")
  rescue NoMatchError
    nil
  end

  def has_transcript_url?
    return true if !transcript_url.nil?
    false
  end

  private

  def process_id(id)
    raise "Unexpected GUID format" unless id =~ /^cpb-aacip(\/|_)\d{2,3}-\w{8}/
    case id
    when /^cpb-aacip\/{1}/
      return id.sub(/\//, '_')
    when /^cpb-aacip_{1}/
      return id
    else
      raise "Unable to parse AAPB ID"
    end
  end

  def get_pbcore
    REXML::Document.new(open(pbcore_url).read)
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
    @media_srcs ||= (1..ci_ids.count).map { |part| "http://americanarchive.org/media/#{uid}?part=#{part}" }
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
