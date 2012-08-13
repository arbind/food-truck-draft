class CityStatesController < ApplicationController
  # GET /city_states
  # GET /city_states.json
  def index
    @city_states = CityState.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @city_states }
    end
  end

  # GET /city_states/1
  # GET /city_states/1.json
  def show
    @city_state = CityState.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @city_state }
    end
  end

  # GET /city_states/new
  # GET /city_states/new.json
  def new
    @city_state = CityState.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @city_state }
    end
  end

  # GET /city_states/1/edit
  def edit
    @city_state = CityState.find(params[:id])
  end

  # POST /city_states
  # POST /city_states.json
  def create
    @city_state = CityState.new(params[:city_state])

    respond_to do |format|
      if @city_state.save
        format.html { redirect_to @city_state, notice: 'City state was successfully created.' }
        format.json { render json: @city_state, status: :created, location: @city_state }
      else
        format.html { render action: "new" }
        format.json { render json: @city_state.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /city_states/1
  # PUT /city_states/1.json
  def update
    @city_state = CityState.find(params[:id])

    respond_to do |format|
      if @city_state.update_attributes(params[:city_state])
        format.html { redirect_to @city_state, notice: 'City state was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @city_state.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /city_states/1
  # DELETE /city_states/1.json
  def destroy
    @city_state = CityState.find(params[:id])
    @city_state.destroy

    respond_to do |format|
      format.html { redirect_to city_states_url }
      format.json { head :no_content }
    end
  end
end
