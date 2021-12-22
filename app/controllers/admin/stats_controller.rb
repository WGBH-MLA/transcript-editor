
class Admin::StatsController < ApplicationController
  include ActionController::MimeResponds
  # before_action :authenticate_moderator!

  # GET /admin
  # GET /admin.json
  def index
    respond_to do |format|
      format.html {
        render :file => "public/#{ENV['PROJECT_ID']}/admin.html"
      }
      format.json {

        if authenticate_moderator!
          @stats = [
            {label: "User Registration Stats", data: User.getStatsByDay},
            {label: "Transcript Edit Stats", data: TranscriptEdit.getStatsByDay}
          ]
        else
          @stats = nil
        end
      }
    end
  end

end
