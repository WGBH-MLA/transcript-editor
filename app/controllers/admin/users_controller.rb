class Admin::UsersController < ApplicationController
  include ActionController::MimeResponds

  before_action :authenticate_admin!

  before_action :set_user, only: [:show, :update, :destroy]

  # GET /admin/users
  # GET /admin/users.json
  def index
    respond_to do |format|
      format.html {
        render :file => "public/#{ENV['PROJECT_ID']}/admin.html"
      }
      format.json {
        @users = User.getAll
        @user_roles = UserRole.getAll
      }
    end
  end

  # PATCH/PUT /admin/users/{id}.json
  def update
    if @user.update(user_params)
      head :no_content
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  private

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:user_role_id)
    end

end
