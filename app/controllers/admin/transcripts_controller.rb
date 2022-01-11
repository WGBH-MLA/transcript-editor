class Admin::TranscriptsController < ApplicationController
  include ActionController::MimeResponds

  before_action :authenticate_admin!

  # GET /admin/transcripts.json
  def index
    respond_to do |format|
      format.json {
        @transcripts = []
      }
    end
  end

end
