class DefaultController < ApplicationController
  def index
    # render the project set in environment
    render :file => Rails.root + "public/#{ENV['PROJECT_ID']}/index.html"
  end

  def admin
    render :file => Rails.root + "public/#{ENV['PROJECT_ID']}/admin.html"
  end
end
