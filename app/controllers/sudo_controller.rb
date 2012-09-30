class SudoController < ApplicationController
  def index
    @look_for = params[:look_for] || params[:q]
    @radius = params[:radius] || params[:r] || 100 # miles
    @page = params[:page] || params[:p] || '1' # page
    @page = @page.to_i

    js_var(look_for: @look_for, radius: @radius, geo_place: @geo_place, geo_coordinates: @geo_coordinates)

    @crafts = Craft.near(@geo_coordinates, @radius).desc(:ranking_score) if @geo_coordinates
    @crafts ||= Craft.near(@geo_place, @radius).desc(:ranking_score) if @geo_place

    @total_crafts_count = @crafts.count
    limit = RESULTS_PER_PAGE
    skip = (@page-1) * RESULTS_PER_PAGE

    @crafts = @crafts.skip(skip).limit(limit)

    @total_pages = 1 + (@total_crafts_count/RESULTS_PER_PAGE).to_i
    js_var(total_crafts_count: @total_crafts_count, page: @page, total_pages: @total_pages)

    if @look_for.present?
      @crafts = @crafts.where(search_tags: @look_for)  if @crafts.present?
      @crafts ||= Craft.where(search_tags: @look_for)
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: nil }
    end
  end

  def tweet_streams
    @craft_streams = CraftStream.all
    @threads = CraftStreamService.instance.threads
    @threads_started = CraftStreamService.instance.start    
  end

  def toggle_approved
    respond_to do |format|
      format.json do
        @craft = Craft.find(params[:id])
        render json: nil and return if @craft.nil?
        @craft.rejected = false
        @craft.approved = @craft.approved ? false : true
        @craft.save!
        render json: { status: @craft.approved }
      end
    end
  end

  def toggle_rejected
    respond_to do |format|
      format.json do
        @craft = Craft.find(params[:id])
        render json: nil and return if @craft.nil?
        @craft.approved = false
        @craft.rejected = @craft.rejected ? false : true
        @craft.save!
        render json: { status: @craft.rejected }
      end
    end
  end

  def toggle_essence
    respond_to do |format|
      format.json do
        @craft = Craft.find(params[:id])
        @essence = Craft.find(params[:essence])
        render json: nil and return if ( @craft.nil? or @essence.nil?)
        @craft.is_in_essence_tags @essence, :toggle
        render json: {essence_tags: @craft.essence_tags }
      end
    end
  end

  def toggle_theme
    respond_to do |format|
      format.json do
        @craft = Craft.find(params[:id])
        @theme = Craft.find(params[:theme])
        render json: nil and return if ( @craft.nil? or @theme.nil?)
        @craft.is_in_theme_tags @theme, :toggle
        render json: {theme_tags: @craft.theme_tags }
      end
    end
  end
      
end
