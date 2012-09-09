class HoverCraftsController < ApplicationController
  # GET /crafts
  # GET /crafts.json
  def index
    @hover_crafts = HoverCraft.where(:fit_score.gte => -5).desc(:fit_score)
    # @hover_crafts = HoverCraft.ready_to_make.desc(:fit_score)
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: nil }
    end
 end

  # GET /hover_crafts/1
  # GET /hover_crafts/1.json
  def show
    @hover_craft = HoverCraft.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @hover_craft }
    end
  end

  # GET /crafts/new
  # GET /crafts/new.json
  def new
    # @hover_craft = HoverCraft.new

    # respond_to do |format|
    #   format.html # new.html.erb
    #   format.json { render json: @hover_craft }
    # end
  end

  # GET /crafts/1/edit
  def edit
    @hover_craft = HoverCraft.find(params[:id])
  end

  # POST /hover_crafts
  # POST /hover_crafts.json
  def create
    @hover_craft = HoverCraft.materialize(params)

    respond_to do |format|
      if @hover_craft
        format.html { redirect_to @hover_craft, notice: 'Craft was materialized.' }
        format.json { render json: @hover_craft, status: :created, location: @hover_craft }
      else
        format.html { render action: "new" }
        format.json { render json: @hover_craft.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /crafts/1
  # PUT /crafts/1.json
  def update
    @hover_craft = HoverCraft.find(params[:id])

    respond_to do |format|
      if @hover_craft.update_attributes(params[:hover_craft])
        format.html { redirect_to @hover_craft, notice: 'Craft was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @hover_craft.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /crafts/1
  # DELETE /crafts/1.json
  def destroy
    @hover_craft = HoverCraft.find(params[:id])
    @hover_craft.destroy

    respond_to do |format|
      format.html { redirect_to hover_crafts_url }
      format.json { head :no_content }
    end
  end
end
