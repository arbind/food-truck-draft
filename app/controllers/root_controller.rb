class RootController < ApplicationController

  def index
    @tweeter = Tweeter.all.first
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: nil }
    end
  end

  def route_subdomain
    @tweeter = Tweeter.all.first
    # view_path   = "root/#{@route_to}/index" if @route_to.present?
    view_path = "root/index"
    respond_to do |format|
      format.html { render view_path }
      format.json { render json: nil }
    end
  end

end
