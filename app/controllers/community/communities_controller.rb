class Community::CommunitiesController < ApplicationController
  layout 'application_community'
  before_action :set_community_community, only: [:show, :edit, :update, :destroy]

  # GET /community/communities
  # GET /community/communities.json
  def index
    @community_communities = Community::Community.all
  end

  # GET /community/communities/1
  # GET /community/communities/1.json
  def show
  end

  # GET /community/communities/new
  def new
    @community_community = Community::Community.new
  end

  # GET /community/communities/1/edit
  def edit
  end

  # POST /community/communities
  # POST /community/communities.json
  def create
    @community_community = Community::Community.new(community_community_params)

    respond_to do |format|
      if @community_community.save
        format.html { redirect_to @community_community, notice: 'Community was successfully created.' }
        format.json { render :show, status: :created, location: @community_community }
      else
        format.html { render :new }
        format.json { render json: @community_community.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /community/communities/1
  # PATCH/PUT /community/communities/1.json
  def update
    respond_to do |format|
      if @community_community.update(community_community_params)
        format.html { redirect_to @community_community, notice: 'Community was successfully updated.' }
        format.json { render :show, status: :ok, location: @community_community }
      else
        format.html { render :edit }
        format.json { render json: @community_community.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /community/communities/1
  # DELETE /community/communities/1.json
  def destroy
    @community_community.destroy
    respond_to do |format|
      format.html { redirect_to community_communities_url, notice: 'Community was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_community_community
      @community_community = Community::Community.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def community_community_params
      params[:community_community]
    end
end