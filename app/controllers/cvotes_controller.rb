class CvotesController < ApplicationController
  # GET /cvotes
  # GET /cvotes.json
  def index
    @cvotes = Cvote.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @cvotes }
    end
  end

  # GET /cvotes/1
  # GET /cvotes/1.json
  def show
    @cvote = Cvote.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @cvote }
    end
  end

  # GET /cvotes/new
  # GET /cvotes/new.json
  def new
    @cvote = Cvote.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @cvote }
    end
  end

  # GET /cvotes/1/edit
  def edit
    @cvote = Cvote.find(params[:id])
  end

  # POST /cvotes
  # POST /cvotes.json
  def create
    @cvote = Cvote.new(params[:cvote])

    respond_to do |format|
      if @cvote.save
        format.html { redirect_to @cvote, notice: 'Cvote was successfully created.' }
        format.json { render json: @cvote, status: :created, location: @cvote }
      else
        format.html { render action: "new" }
        format.json { render json: @cvote.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /cvotes/1
  # PUT /cvotes/1.json
  def update
    @cvote = Cvote.find(params[:id])

    respond_to do |format|
      if @cvote.update_attributes(params[:cvote])
        format.html { redirect_to @cvote, notice: 'Cvote was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @cvote.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /cvotes/1
  # DELETE /cvotes/1.json
  def destroy
    @cvote = Cvote.find(params[:id])
    @cvote.destroy

    respond_to do |format|
      format.html { redirect_to cvotes_url }
      format.json { head :no_content }
    end
  end
end
