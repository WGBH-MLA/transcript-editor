class FlagsController < ApplicationController
  before_action :set_flag, only: [:show, :update, :destroy]

  # GET /flags.json
  def index
    @flags = []
    @flags = Flag.getByLine(params[:transcript_line_id]) if params[:transcript_line_id]
  end

  # GET /flags/1.json
  def show
  end

  # POST /flags.json
  def create
    @flag = nil
    params[:flag][:session_id] = session.id.to_s
    flag = params[:flag]

    # Retrieve existing edit for user or session
    if user_signed_in?
      params[:flag][:user_id] = current_user.id
      @flag = Flag.find_by user_id: current_user.id, transcript_line_id: flag[:transcript_line_id], is_resolved: 0
    else
      @flag = Flag.find_by session_id: flag[:session_id], transcript_line_id: flag[:transcript_line_id], is_resolved: 0
    end

    success = false
    # This is a new flag
    if @flag.nil?
      @flag = Flag.new(flag_params)
      if @flag.save
        line = TranscriptLine.find flag[:transcript_line_id]
        line.incrementFlag()
        render json: @flag, status: :created, location: @flag
        success = true
      end

    # This is an existing edit
    else
      if @flag.update(flag_params)
        head :no_content
        success = true
      end
    end

    # An error occurred
    unless success
      render json: @flag.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /flags/1.json
  def update
    @flag = Flag.find(params[:id])

    if @flag.update(flag_params)
      head :no_content
    else
      render json: @flag.errors, status: :unprocessable_entity
    end
  end

  # DELETE /flags/1.json
  def destroy
    @flag.destroy

    head :no_content
  end

  private

    def set_flag
      @flag = Flag.find(params[:id])
    end

    def flag_params
      params.require(:flag).permit(:transcript_id, :transcript_line_id, :flag_type_id, :session_id, :user_id, :text, :is_resolved)
    end
end
