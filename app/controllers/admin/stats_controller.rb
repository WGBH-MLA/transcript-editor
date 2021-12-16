class Admin::StatsController < ApplicationController
  include ActionController::MimeResponds
  before_action :authenticate_user!, :authenticate_moderator!

  # GET /admin
  # GET /admin.json
  def index
    respond_to do |format|
      format.html {
        render :file => "public/#{ENV['PROJECT_ID']}/admin.html"
      }
      format.json {
        @stats = [
          {label: "User Registration Stats", data: User.getStatsByDay},
          {label: "Transcript Edit Stats", data: TranscriptEdit.getStatsByDay}
        ]
      }
    end
  end

end
