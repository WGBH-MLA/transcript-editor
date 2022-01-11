class DefaultController < ApplicationController
  def index
    # render the project set in environment
    puts "FULL HEADERS DEFAULT"
    puts request.headers
    render :file => Rails.root + "public/index.html"
  end

  def admin
    puts "FULL HEADERS ADMIN"
    puts request.headers
    render :file => Rails.root + "public/admin.html"
  end
end
