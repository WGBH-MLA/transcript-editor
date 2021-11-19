class TranscriptSpeakerEditsController < ApplicationController
  before_action :set_transcript_speaker_edit, only: [:show, :update, :destroy]

  # GET /transcript_speaker_edits.json
  def index
    @transcript_speaker_edits = []

    render json: @transcript_speaker_edits
  end

  # GET /transcript_speaker_edits/1.json
  def show
    @transcript_speaker_edit = nil

    render json: @transcript_speaker_edit
  end

  # POST /transcript_speaker_edits.json
  def create
    @transcript_speaker_edit = nil
    params[:transcript_speaker_edit][:session_id] = session.id.to_s
    t = params[:transcript_speaker_edit]
    line = TranscriptLine.find t[:transcript_line_id]
    project = Project.getActive

    unless line
      head :no_content
      return
    end

    # Retrieve existing edit for user or session
    if user_signed_in?
      params[:transcript_speaker_edit][:user_id] = current_user.id
      @transcript_speaker_edit = TranscriptSpeakerEdit.find_by user_id: current_user.id, transcript_line_id: t[:transcript_line_id]
    else
      @transcript_speaker_edit = TranscriptSpeakerEdit.find_by session_id: t[:session_id], transcript_line_id: t[:transcript_line_id]
    end

    success = false
    # This is a new edit
    if @transcript_speaker_edit.nil?
      @transcript_speaker_edit = TranscriptSpeakerEdit.new(transcript_speaker_edit_params)
      if @transcript_speaker_edit.save
        line.recalculateSpeaker(nil, project)
        render json: @transcript_speaker_edit, status: :created
        success = true
      end

    # This is an existing edit
    else
      if @transcript_speaker_edit.update(transcript_speaker_edit_params)
        line.recalculateSpeaker(nil, project)
        head :no_content
        success = true
      end
    end

    # An error occurred
    unless success
      render json: @transcript_speaker_edit.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /transcript_speaker_edits/1.json
  def update
    @transcript_speaker_edit = TranscriptSpeakerEdit.find(params[:id])

    if @transcript_speaker_edit.update(transcript_speaker_edit_params)
      head :no_content
    else
      render json: @transcript_speaker_edit.errors, status: :unprocessable_entity
    end
  end

  # DELETE /transcript_speaker_edits/1.json
  def destroy
    @transcript_speaker_edit.destroy

    head :no_content
  end

  private

    def set_transcript_speaker_edit
      @transcript_speaker_edit = TranscriptSpeakerEdit.find(params[:id])
    end

    def transcript_speaker_edit_params
      params.require(:transcript_speaker_edit).permit(:transcript_id, :transcript_line_id, :user_id, :session_id, :speaker_id)
    end
end
