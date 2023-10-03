class User < ActiveRecord::Base
  extend Devise::Models

  # Include default devise modules.
  devise :database_authenticatable, :rememberable, :trackable, :validatable, :omniauthable
  include DeviseTokenAuth::Concerns::User

  belongs_to :user_role

  def incrementLinesEdited(amount=1)
    update(lines_edited: lines_edited + amount)
  end

  def recalculate(edits=nil)
    edits ||= TranscriptEdit.getByUser(id)
    if edits
      update(lines_edited: edits.length)
    end
  end

  def setRole(role_name)
    user_role = UserRole.find_by name: role_name
    if user_role && user_role.id != user_role_id
      update(user_role_id: user_role.id)
    end
  end

  def isAdmin?
    role = user_role
    role = UserRole.find user_role_id if !role && user_role_id > 0
    role && role.name == "admin"
  end

  def isModerator?
    role = user_role
    role = UserRole.find user_role_id if !role && user_role_id > 0
    role && (role.name == "moderator" || role.name == "admin")
  end

  def self.getAll
    User.order("lines_edited DESC").limit(1000)
  end

  def self.numberTranscriptEditsByUser(start_date=Time.new(2000,1,1), end_date=Time.now, page)
    data = {total: User.count}
    users = {}
    User.order(created_at: :desc).offset(page * 8).limit(8).each do |user|
      transcript_edit_window = TranscriptEdit.where(user_id: user.id).where('created_at >= ?', start_date).where('created_at <= ?', end_date)
      last_edit = transcript_edit_window.order(created_at: :desc).first

      if last_edit
        users[user.id] = {
          name: user.name,
          number_edits: transcript_edit_window.count,
          last_edited_record: last_edit.transcript.uid,
          last_edit_date: last_edit.created_at
        }
      else
        # no transcript edit found in specified timeframe
        users[user.id] = {
          name: user.name,
          number_edits: 0,
          last_edited_record: "N/A",
          last_edit_date: "N/A"
        }

      end
    end

    data[:users] = users
    data
  end
end
