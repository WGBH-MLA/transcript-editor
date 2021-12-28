class Admin::StatsController < ApplicationController
  include ActionController::MimeResponds
  before_action :authenticate_moderator!

  # GET /admin.json
  def index
    puts "TOP OF STATS CONTROLLER"
    puts request.inspect
    puts session.inspect
    puts current_user.inspect
    puts "END LOGGO"

    respond_to do |format|
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
