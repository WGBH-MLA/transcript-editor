class TranscriptLine < ActiveRecord::Base

  include PgSearch
  multisearchable :against => [:original_text, :guess_text]
  pg_search_scope :search_by_all_text, :against => [:guess_text, :original_text] # User text weighted more than original text
  pg_search_scope :search_by_original_text, :against => :original_text
  pg_search_scope :search_by_guess_text, :against => :guess_text

  belongs_to :transcript_line_status
  belongs_to :transcript, touch: true
  has_many :transcript_edits
  has_many :flags

  default_scope { order(:sequence) }

  def best_text
    texts = [text, guess_text, original_text]
    texts.find { |t| !t.blank? }
  end

  def incrementFlag
    new_flag_count = flag_count + 1
    update(flag_count: new_flag_count)
  end

  def resolve
    update(flag_count: 0)
  end

  def start_time_string
    Time.at(start_time/1000).utc.strftime("%H:%M:%S.%L")
  end

  def end_time_string
    Time.at(end_time/1000).utc.strftime("%H:%M:%S.%L")
  end

  def self.getEdited
    TranscriptLine.joins(:transcript_edits).distinct
  end

  def self.getEditedByTranscriptId(transcript_id)
    TranscriptLine.joins(:transcript_edits).where(transcript_lines:{transcript_id: transcript_id}).distinct
  end

  def self.getByTranscriptWithSpeakers(transcript_id)
    TranscriptLine
      .select("transcript_lines.*, COALESCE(speakers.name, '') AS speaker_name")
      .joins("LEFT OUTER JOIN speakers ON transcript_lines.speaker_id = speakers.id")
      .where(transcript_id: transcript_id)
  end

  def self.getByTranscriptSequence(transcript_id, sequence)
    TranscriptLine
      .where(transcript_id: transcript_id, sequence: sequence).first
  end

  def self.recalculateById(transcript_line_id)
    line = TranscriptLine.find transcript_line_id
    line.recalculate if line
  end

  # Update the line's status and best-guess text based on contributed edits
  def recalculate(edits=nil, project=nil)
    edits ||= TranscriptEdit.getByLine(id)
    project ||= Project.getActive
    statuses = TranscriptLineStatus.allCached

    # Init status & text
    status_id = 1
    best_guess_text = original_text
    final_text = ""
    consensus = project[:data]["consensus"]

    # Filter out blank text or text that is the original text unless they are submitted by super users
    edits_filtered = []
    if edits.length > 0
      edits_filtered = edits.select { |edit| !edit[:text].blank? && edit[:text] != original_text || edit[:user_hiearchy] >= consensus["superUserHiearchy"] }
    end

    # Only original or blank text was found; use all edits
    if edits_filtered.length <= 0 && edits.length >= consensus["minLinesForConsensusNoEdits"]
      edits_filtered = edits.select { |edit| true }
    end

    # Set best guess text
    best_edit = chooseBestEdit(edits_filtered, project)
    unless best_edit.nil? || best_edit[:edit].nil?
      best_guess_text = best_edit[:edit][:text]
    end

    # Super users override all others
    if status_id <= 1 && !best_edit.nil? && !best_edit[:edit].nil? && best_edit[:edit][:user_hiearchy] >= consensus["superUserHiearchy"]
      completed_status = statuses.find{|s| s[:name]=="completed"}
      status_id = completed_status[:id]
      final_text = best_guess_text
    end

    # Candidate for consensus
    if status_id <= 1 && edits_filtered.length >= consensus["minLinesForConsensus"]
      unless best_edit.nil? || best_edit[:group].nil?
        # Determine what percent agree
        percent_agree = 1.0 * best_edit[:group][:count] / edits_filtered.length
        # puts "Best Edit #{best_edit}"
        # Mark as completed
        if percent_agree >= consensus["minPercentConsensus"]
          completed_status = statuses.find{|s| s[:name]=="completed"}
          status_id = completed_status[:id]
          final_text = best_guess_text
        end
      end
    end

    # Candidate for consensus due to mathematical certainty
    # E.g. two people submit the same edit; it doesn't matter who the third is
    if status_id <= 1 && edits_filtered.length > 1 && edits_filtered.length < consensus["minLinesForConsensus"]
      unless best_edit.nil? || best_edit[:group].nil?
        # Assume there are minimum edits made for consensus
        percent_agree = 1.0 * best_edit[:group][:count] / consensus["minLinesForConsensus"]
        # Mark as completed
        if percent_agree >= consensus["minPercentConsensus"]
          completed_status = statuses.find{|s| s[:name]=="completed"}
          status_id = completed_status[:id]
          final_text = best_guess_text
        end
      end
    end

    # Ready for review
    if status_id <= 1 && edits_filtered.length >= consensus["maxLineEdits"]
      reviewing_status = statuses.find{|s| s[:name]=="reviewing"}
      status_id = reviewing_status[:id]
    end

    # Edits have been received
    if status_id <= 1 && edits_filtered.length > 0
      editing_status = statuses.find{|s| s[:name]=="editing"}
      status_id = editing_status[:id]
    end

    # Update line if it has changed
    transcript = Transcript.find(transcript_id)
    status_changed = (status_id != transcript_line_status_id)
    old_status_id = transcript_line_status_id
    if status_changed || best_guess_text != guess_text
      update(transcript_line_status_id: status_id, guess_text: best_guess_text, text: final_text)

      # Update transcript if line status has changed
      if status_changed
        transcript.delta(old_status_id, status_id, statuses)
      end
    end

    # Update user count
    transcript.updateUsersContributed()
  end

  def recalculateSpeaker(edits=nil, project=nil)
    edits ||= TranscriptSpeakerEdit.getByLine(id)
    project ||= Project.getActive
    consensus = project[:data]["consensus"]
    best_speaker_id = 0

    # Check if there's any edits by priority users (e.g. moderators, admins)
    if edits.length > 0
      edits_priority = edits.select { |edit| edit[:user_hiearchy] >= consensus["superUserHiearchy"] }
      edits = edits_priority.select { |edit| true } if edits_priority.length > 0
    end

    if edits.length > 0
      # Group the edits by speaker_id
      groups = edits.group_by{|edit| edit.speaker_id}
      # Convert groups from hash to array
      groups = groups.collect {|group_speaker_id, group_edits| {speaker_id: group_speaker_id, count: group_edits.length} }
      # Sort by frequency of speaker_id
      groups = groups.sort_by { |group| group[:count] * -1 }
      best_speaker_id = groups[0][:speaker_id]
    end

    update(speaker_id: best_speaker_id) if best_speaker_id != speaker_id
  end

  private

  def chooseBestEdit(edits, project)
    best_group = nil
    best_edit = nil
    consensus = project[:data]["consensus"]

    # Check if there's any edits by priority users (e.g. moderators, admins)
    if edits.length > 0
      edits_priority = edits.select { |edit| edit[:user_hiearchy] >= consensus["superUserHiearchy"] }
      if edits_priority.length > 0
        edits = edits_priority.select { |edit| true }
        best_group = {text: edits[0].normalizedText, count: 1}
        best_edit = edits[0]
      end
    end

    # Init to selecting the first
    best_group = {text: edits[0].normalizedText, count: 1} if edits.length > 0
    best_edit = edits[0] if edits.length > 0

    if edits.length > 1

      # Group the edits by normalized text
      groups = edits.group_by{|edit| edit.normalizedText}
      # Convert groups from hash to array
      groups = groups.collect {|group_text, group_edits| {text: group_text, count: group_edits.length} }
      # Sort by frequency of text
      groups = groups.sort_by { |group| group[:count] * -1 }
      best_group = groups[0]

      # No group has more than one edit; treat them all the same
      best_edits = edits.select {|edit| true }
      # There's a group that has more than one edit, choose the one with the most
      if best_group[:count] > 1
        # Retrieve the edits based on the best group's text
        best_edits = edits.select { |edit| edit.normalizedText==best_group[:text] }
      end

      # Sort the edits
      best_edits = best_edits.sort_by { |edit|
        score = 0
        score -= 1 if edit[:text] =~ /\d/ # Plus 1 if contains a number
        score -= edit[:text].scan(/[A-Z]+/).length  # Count uppercase letters
        score -= edit[:text].scan(/[^0-9A-Za-z ]/).length # Count puncuation
        score -= edit[:text].scan(/\bu+h+m*\b|\bu+m+\b/).length # Count umm's, uhh's, uhhm's
        score -= edit[:user_hiearchy] # Give a preference users with higher hiearchy
        score
      }
      # puts "Best Edits #{best_edits}"
      best_edit = best_edits[0]
    end

    {
      edit: best_edit,
      group: best_group
    }
  end

end
