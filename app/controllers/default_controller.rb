class DefaultController < ApplicationController
  def index
    # render the project set in environment
    render :file => Rails.root + "public/index.html"
  end

  def admin
    render :file => Rails.root + "public/admin.html"
  end
end
