class MetrosController < ApplicationController
  # GET /metros
  # GET /metros.json
  def index
    @metros = Metro.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @metros }
    end
  end

  # GET /metros/1
  # GET /metros/1.json
  def show
    @metro = Metro.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @metro }
    end
  end

  # GET /metros/new
  # GET /metros/new.json
  def new
    @metro = Metro.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @metro }
    end
  end

  # GET /metros/1/edit
  def edit
    @metro = Metro.find(params[:id])
  end

  # POST /metros
  # POST /metros.json
  def create
    @metro = Metro.new(params[:metro])

    respond_to do |format|
      if @metro.save
        format.html { redirect_to @metro, notice: 'Metro was successfully created.' }
        format.json { render json: @metro, status: :created, location: @metro }
      else
        format.html { render action: "new" }
        format.json { render json: @metro.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /metros/1
  # PUT /metros/1.json
  def update
    @metro = Metro.find(params[:id])

    respond_to do |format|
      if @metro.update_attributes(params[:metro])
        format.html { redirect_to @metro, notice: 'Metro was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @metro.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /metros/1
  # DELETE /metros/1.json
  def destroy
    @metro = Metro.find(params[:id])
    @metro.destroy

    respond_to do |format|
      format.html { redirect_to metros_url }
      format.json { head :no_content }
    end
  end
end
