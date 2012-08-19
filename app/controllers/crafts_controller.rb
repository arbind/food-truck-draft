class CraftsController < ApplicationController
  # GET /crafts
  # GET /crafts.json
  def index
    @crafts = Craft.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @crafts }
    end
  end

  # GET /crafts/1
  # GET /crafts/1.json
  def show
    @craft = Craft.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @craft }
    end
  end

  # GET /crafts/new
  # GET /crafts/new.json
  def new
    @craft = Craft.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @craft }
    end
  end

  # GET /crafts/1/edit
  def edit
    @craft = Craft.find(params[:id])
  end

  # POST /crafts
  # POST /crafts.json
  def create
    @craft = Craft.new(params[:craft])

    respond_to do |format|
      if @craft.save
        format.html { redirect_to @craft, notice: 'Craft was successfully created.' }
        format.json { render json: @craft, status: :created, location: @craft }
      else
        format.html { render action: "new" }
        format.json { render json: @craft.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /crafts/1
  # PUT /crafts/1.json
  def update
    @craft = Craft.find(params[:id])

    respond_to do |format|
      if @craft.update_attributes(params[:craft])
        format.html { redirect_to @craft, notice: 'Craft was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @craft.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /crafts/1
  # DELETE /crafts/1.json
  def destroy
    @craft = Craft.find(params[:id])
    @craft.destroy

    respond_to do |format|
      format.html { redirect_to crafts_url }
      format.json { head :no_content }
    end
  end
end
