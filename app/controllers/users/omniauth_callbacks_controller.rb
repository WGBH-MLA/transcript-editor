class Users::OmniauthCallbacksController < DeviseTokenAuth::OmniauthCallbacksController

  # before_action :set_user_session
  after_action :handle_user_sessions

  # def google_oauth2
  #   puts "Hey Its Us In The Method!"

  #    @user = User.from_omniauth(request.env["omniauth.auth"])
  #     session[:google_oauth2] = request.env["omniauth.auth"]["uid"]
  #    redirect_to root_pathk
  # end

  def handle_user_sessions
    # puts "Session After: #{session[:previously_not_logged_in]} , #{session.id}"
    if session[:previously_not_logged_in] && user_signed_in?

      # Assume previous session belongs to user
      TranscriptEdit.updateUserSessions(session.id.to_s, current_user.id)
      Flag.updateUserSessions(session.id.to_s, current_user.id)

      # Check if user is an admin
      project = Project.getActive
      admin_emails = project[:data]["adminEmails"]
      if admin_emails.include?(current_user.email) && (!current_user.user_role || current_user.user_role.name != "admin")
        current_user.setRole("admin")
      end
    end
  end

  def set_user_session
    # puts "Session Before: #{session[:previously_not_logged_in]} , #{session.id}"

    session[:previously_not_logged_in] = false
    # puts request.inspect
    # puts session.inspect

    puts "Hello again!!!"


    unless user_signed_in?
      session[:previously_not_logged_in] = true
    end

    # only a test
    # redirect_to redirect_callbacks && return
  end
end
