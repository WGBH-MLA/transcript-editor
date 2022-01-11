class Admin::StatsController < ApplicationController
  include ActionController::MimeResponds
  before_action :authenticate_moderator!

  # GET /stats.json
  def index
    respond_to do |format|
      format.json {
        @stats = [
          {label: "User Registration Stats", data: User.getStatsByDay},
          {label: "Transcript Edit Stats", data: TranscriptEdit.getStatsByDay}
        ]
      }
    end
  end

end
