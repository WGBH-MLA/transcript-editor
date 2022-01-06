class Admin::FlagsController < ApplicationController
  include ActionController::MimeResponds

  before_action :authenticate_moderator!

  # GET /admin/flags.json
  # GET /moderator
  def index
    respond_to do |format|
      format.json {
        @flags = Flag.getUnresolved()
      }
    end
  end

end
