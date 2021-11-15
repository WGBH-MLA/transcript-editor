require 'sony_ci_api'
require 'nokogiri'

class MediaController < ApplicationController

  AAPB_HOST = "https://americanarchive.org"
  def show
    guid = params['id']
    transcript = Transcript.where(uid: guid).first
    if transcript

      pbcore = RestClient.get(AAPB_HOST + "/catalog/#{ guid }.pbcore")
      doc = Nokogiri::XML(xml)
      doc.remove_namespaces!
      ci_node = doc.xpath( %(/*/pbcoreIdentifier[@source="Sony Ci"]) ).first
      ci_id = ci_node.text if ci_node
      if ci_id
        redirect_to SonyCiApi::Client.new(Rails.root + 'config/ci.yml').asset_download(ci_id)['location']
      else
        render nothing: true, status: :not_found  
      end
    else
      render nothing: true, status: :unauthorized
    end
  end
end
