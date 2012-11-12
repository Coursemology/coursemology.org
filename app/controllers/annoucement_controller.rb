class AnnouncementsController < ApplicationController
  load_and_authorize_resource

  # GET /annoucements
  # GET /annoucements.json
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @annoucements }
    end
  end

  # GET /annoucements/1
  # GET /annoucements/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @annoucement }
    end
  end

  # GET /annoucements/new
  # GET /annoucements/new.json
  def new
    puts @annoucement.to_json
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @annoucement }
    end
  end

  # GET /annoucements/1/edit
  def edit
  end

  # POST /annoucements
  # POST /annoucements.json
  def create
    @annoucement.creator = current_user
    respond_to do |format|
      if @annoucement.save
        format.html { redirect_to course_annoucement_url(@course, @annoucement),
                      notice: 'annoucement was successfully created.' }
        format.json { render json: @annoucement, status: :created, location: @annoucement }
      else
        format.html { render action: "new" }
        format.json { render json: @annoucement.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /annoucements/1
  # PUT /annoucements/1.json
  def update
    respond_to do |format|
      if @annoucement.update_attributes(params[:annoucement])
        format.html { redirect_to @annoucement, notice: 'annoucement was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @annoucement.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /annoucements/1
  # DELETE /annoucements/1.json
  def destroy
    @annoucement.destroy

    respond_to do |format|
      format.html { redirect_to annoucements_url }
      format.json { head :no_content }
    end
  end
end