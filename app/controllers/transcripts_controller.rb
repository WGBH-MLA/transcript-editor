class TranscriptsController < ApplicationController
  include ActionController::MimeResponds

  before_action :set_transcript, only: [:show, :update, :destroy, :aapb]

  # GET /transcripts.json
  def index
    project = Project.getActive
    @project_settings = project[:data]
    @transcripts = Transcript.getForHomepage(params[:page])
  end

  # GET /search?sort_by=completeness&order=desc&collection_id=1&q=amy&page=1
  # GET /search.json?sort_by=completeness&order=desc&collection_id=1&q=amy&page=1
  def search
    respond_to do |format|
      format.html {
        redirect_to root_path
      }
      format.json {
        project = Project.getActive
        @project_settings = project[:data]
        @transcripts = Transcript.search(search_params)
      }
    end
  end

  # GET /transcripts/the-uid
  # GET /transcripts/the-uid.json
  def show
    respond_to do |format|
      format.html {
        render :file => "public/#{ENV['PROJECT_ID']}/index.html"
      }
      format.json {
        @user_role = nil
        @user_edits = []
        @transcript_line_statuses = TranscriptLineStatus.allCached
        @transcript_speakers = TranscriptSpeaker.getByTranscriptId(@transcript.id)
        @flag_types = FlagType.byCategory("error")
        @user_flags = []

        if user_signed_in?
          @user_edits = TranscriptEdit.getByTranscriptUser(@transcript.id, current_user.id)
          @user_role = current_user.user_role
          @user_flags = Flag.getByTranscriptUser(@transcript.id, current_user.id)
        else
          @user_edits = TranscriptEdit.getByTranscriptSession(@transcript.id, session.id)
          @user_flags = Flag.getByTranscriptSession(@transcript.id, session.id)
        end
      }
    end
  end

  # Adds endpoint for AAPB formatted transcript
  def aapb
    respond_to do |format|
      format.html { redirect_to action: 'aapb', id: @transcript.uid, format: 'json' }
      format.json
    end
  end

  # POST /transcripts.json
  def create
    @transcript = Transcript.new(transcript_params)

    if @transcript.save
      render json: @transcript, status: :created, location: @transcript
    else
      render json: @transcript.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /transcripts/the-uid.json
  def update
    return 400 unless params[:released] == 'true'
    if @transcript.update({released: true})
      head :no_content
    else
      render json: @transcript.errors, status: :unprocessable_entity
    end
  end

  # DELETE /transcripts/the-uid.json
  def destroy
    @transcript.destroy

    head :no_content
  end

  def release_count
    return render json: {data: Transcript.where(released: false, percent_completed: 100).all.map {|t| t.uid }}, status: 200
  end

  def all_uids
    return render json: {data: Transcript.all.map {|t| t.uid }}, status: 200
  end

  private

    def set_transcript
      @transcript = Transcript.find_by(uid: params[:id])
    end

    def transcript_params
      params.require(:transcript).permit(:title, :description, :url, :audio_url, :image_url, :collection_id, :notes, :transcript_status_id)
    end

    def search_params
      params.permit(:sort_by, :order, :collection_id, :q, :page, :deep)
    end
end
