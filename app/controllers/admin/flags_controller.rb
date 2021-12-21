class Admin::FlagsController < ApplicationController
  include ActionController::MimeResponds

  # before_action :authenticate_moderator!

  # GET /admin/flags
  # GET /admin/flags.json
  # GET /moderator
  def index
    puts "BUT WHAT ABOUT THIS!"
    puts current_user.inspect

    respond_to do |format|
      format.html {
        render :file => "public/#{ENV['PROJECT_ID']}/admin.html"
      }
      format.json {
        @flags = Flag.getUnresolved()
      }
    end
  end

end
