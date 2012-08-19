class NizersController < ApplicationController
  # GET /nizers
  # GET /nizers.json
  def index
    @nizers = Nizer.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @nizers }
    end
  end

  # GET /nizers/1
  # GET /nizers/1.json
  def show
    @nizer = Nizer.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @nizer }
    end
  end

  # GET /nizers/new
  # GET /nizers/new.json
  def new
    @nizer = Nizer.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @nizer }
    end
  end

  # GET /nizers/1/edit
  def edit
    @nizer = Nizer.find(params[:id])
  end

  # POST /nizers
  # POST /nizers.json
  def create
    @nizer = Nizer.new(params[:nizer])

    respond_to do |format|
      if @nizer.save
        format.html { redirect_to @nizer, notice: 'Nizer was successfully created.' }
        format.json { render json: @nizer, status: :created, location: @nizer }
      else
        format.html { render action: "new" }
        format.json { render json: @nizer.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /nizers/1
  # PUT /nizers/1.json
  def update
    @nizer = Nizer.find(params[:id])

    respond_to do |format|
      if @nizer.update_attributes(params[:nizer])
        format.html { redirect_to @nizer, notice: 'Nizer was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @nizer.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /nizers/1
  # DELETE /nizers/1.json
  def destroy
    @nizer = Nizer.find(params[:id])
    @nizer.destroy

    respond_to do |format|
      format.html { redirect_to nizers_url }
      format.json { head :no_content }
    end
  end
end
