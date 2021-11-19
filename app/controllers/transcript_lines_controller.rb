class TranscriptLinesController < ApplicationController

  before_action :set_transcript_line, only: [:resolve]

  # POST /transcript_lines/1/resolve.json
  def resolve

    if is_admin? && !@transcript_line.nil?
      @transcript_line.resolve()
      Flag.resolve(@transcript_line.id)
    end

    head :no_content
  end

  private

    def set_transcript_line
      @transcript_line = TranscriptLine.find(params[:id])
    end

    def transcript_line_params
      params.require(:transcript_line).permit(:transcript_id, :text)
    end 

end
