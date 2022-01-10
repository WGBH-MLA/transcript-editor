class DefaultController < ApplicationController
  def index
    # render the project set in environment
    render :file => Rails.root + "public/assets/index.html"
  end

  def admin
    render :file => Rails.root + "public/assets/admin.html"
  end
end
