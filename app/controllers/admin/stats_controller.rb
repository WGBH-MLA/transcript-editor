class Admin::StatsController < ApplicationController
  include ActionController::MimeResponds
  after_action :authenticate_moderator!

  # GET /admin
  # GET /admin.json
  def index
    puts "TOP OF STATS CONTROLLER"

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

    puts "bottom of stats controller"
  end

end
