class ApplicationController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken

  # Allow us to use JBuilder
  include ActionController::ImplicitRender
  before_action :touch_session

  # Ensure a session id is available for all!
  def touch_session
    session[:touched] = 1
  end

  def is_admin?
    user_signed_in? && current_user.isAdmin?
  end

  def is_moderator?
    user_signed_in? && current_user.isModerator?
  end

  def authenticate_admin!
    unless is_admin?
      if is_moderator?
        redirect_to moderator_url
        return
      else
        render json: {
          error: 1,
          message: 'You must log in as admin to access this section'
        }
        return
      end
    end
  end

  def authenticate_moderator!
    unless is_moderator?
      render json: {
        error: 1,
        message: 'You must log in as admin or moderator to access this section'
      }
      return
    end
  end
end
