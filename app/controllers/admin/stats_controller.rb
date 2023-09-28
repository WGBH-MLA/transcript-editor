class Admin::StatsController < ApplicationController
  include ActionController::MimeResponds
  before_action :get_timeframe, :get_page

  def get_page
    @page = params[:page] ? params[:page].to_i : 0
  end

  def get_timeframe
    @start_date = nil
    @end_date = nil

    if params[:timeframe]
      case params[:timeframe]
      when "day"
        @start_date = 1.day.ago
        @end_date = Time.now
      when "week"
        @start_date = 1.week.ago
        @end_date = Time.now
      when "month"
        @start_date = 1.month.ago
        @end_date = Time.now
      when "year"
        @start_date = 1.year.ago
        @end_date = Time.now
      when "all"
        @start_date = Time.new(2000,1,1)
        @end_date = Time.now
      end
    end
  end

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
  def user_data
    data = User.numberTranscriptEditsByUser(@start_date, @end_date, @page)
    respond_to do |format|
      format.json {
        render json: {data: data}
      }
    end
  end

  def transcripts_completed_data
    data = Transcript.transcriptsCompleted(@start_date, @end_date, @page)
    respond_to do |format|
      format.json {
        render json: {data: data}
      }
    end
  end

  def edit_activity_data
    data = Transcript.editActivity(@start_date, @end_date, @page)
    respond_to do |format|
      format.json {
        render json: {data: data}
      }
    end
  end

  def graph_data
    data = Transcript.transcriptGraphData(Time.now - 36.months)
    respond_to do |format|
      format.json {
        render json: {data: data}  
      }
    end
  end

  def collection_data
    data = Collection.percentCompleted(@page)
    respond_to do |format|
      format.json {
        render json: {data: data}  
      }
    end
  end

  def collection_guids
    collection = Collection.find(params[:id])
    raise ActiveRecord::NotFound unless collection
    @data = collection.incompleteGuids
    render 'admin/stats/collection_guids'
  end
end
