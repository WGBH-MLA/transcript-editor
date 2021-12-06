class User < ActiveRecord::Base
  extend Devise::Models

  # Include default devise modules.
  devise :database_authenticatable,
          # :recoverable, :confirmable, :registerable,
          :rememberable, :trackable, :validatable
  include DeviseTokenAuth::Concerns::User
  # include messes up the following, must be here
  devise :omniauthable

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

  def self.getStatsByDay
    Rails.cache.fetch("#{ENV['PROJECT_ID']}/users/stats", expires_in: 10.minutes) do
      User
        .select('DATE(created_at) AS date, COUNT(*) AS count')
        .group('DATE(created_at)')
        .order('DATE(created_at)')
    end
  end

end
