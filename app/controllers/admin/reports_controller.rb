class Admin::ReportsController < ApplicationController
  before_action :authenticate_admin!
  before_action :get_date_params

  # GET /reports/edits.json
  def edits
    @edits = TranscriptEdit.getReport(@start_date, @end_date)
  end

  # GET /reports/transcripts.json
  def transcripts
    @transcripts = Transcript.getReport()
  end

  # GET /reports/users.json
  def users
    @users = User.getReport()
  end

  private

    def get_date_params
      # default to all time
      @start_date = 10.years.ago
      @end_date = DateTime.now

      # look for parameters
      @start_date = params[:start].to_datetime unless params[:start].blank?
      @end_date = params[:end].to_datetime unless params[:end].blank?
    end

end
