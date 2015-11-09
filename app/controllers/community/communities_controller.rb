class Community::CommunitiesController < ApplicationController
  include ControllerCaching
  layout 'visify', only: [:map]
  after_filter :allow_iframe, only: [:map]

  before_action :set_community_community, only: [:show, :edit, :update, :destroy]
  before_action :set_area, only: [:index, :map]

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

  def group_edit
    @town_select = unless params[:area_id].blank?
                     town_select = Town.where(:id => params[:area_id]).first
                     { :id => town_select[:id].to_s, :title => town_select[:title] }
                   end || { }
  end

  def load

  end

  def get_communities
    @community_communities = Community::Community.all.where(:town_id => params[:area_id])
    render partial: 'communities'
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

    unless community_community_params[:coordinates].nil?
      @community_community.update(:coordinates => eval(community_community_params[:coordinates]))
    end

    respond_to do |format|
      if @community_community.update(community_community_params.except!(:coordinates))
        format.js
        format.json { head :no_content }
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
      format.js
      format.json { head :no_content }
    end
  end

  def map
  end

  def geo_json
    result = []

    if params[:area_title]
      town_id = Town.where(:title => params[:area_title]).first['id']
      Community::Community.all.where(:town_id => town_id).each do |community|
        geo = build_community(community)
        result << geo unless geo.blank?
      end
    else
      towns =
          case params[:type]
            when 'areas'
              Town.areas
            else
              Town.cities + Town.towns
          end
      towns.reject{|town| town.level != 1 && town.level != 13}.each do |town|
        geo = case params[:type]
          when 'areas'
            build_area(town)
          else
            build_point(town)
        end
        result << geo unless geo.blank?
      end
    end

    @geo_json = {
        "type" => "FeatureCollection",
        "features" => result
    }

    respond_to do |format|
      format.json { render json: @geo_json }
    end
  end

  def build_area(town)
    unless town[:coordinates].blank?
      {
          type: "Feature",
          geometry: {
              type: town[:geometry_type],
              coordinates: town[:coordinates]
          },
          properties: {
              id: "#{town[:id]}",
              title: town.title,
              level:town.get_level,
              communities_count:town.community_communities.length,
              bounds: town.bounds,
              center: town.center
          }
      }
    end
  end

  def build_point(town)
    unless town[:coordinates].blank?
      {
          type: "Feature",
          geometry: {
              type: 'Point',
              coordinates: town[:coordinates]
          },
          properties: {
              id: "#{town[:id]}",
              title: town.title,
              level:town.get_level,
              communities_count:town.community_communities.length
          }
      }
    end
  end

  def build_community(community)
    unless community[:coordinates].blank?
      {
          type: "Feature",
          geometry: {
              type: community[:geometry_type],
              coordinates: community[:coordinates]
          },
          properties: {
              id: "#{community[:id]}",
              title: community.title,
              link: community.link,
              participants: community.participants,
              agree: community.agree,
              color: community.color,
              icon: community.icon
          }
      }
    end
  end

  private

    def allow_iframe
      response.headers['x-frame-options'] = 'ALLOWALL'
      response.headers['Access-Control-Allow-Origin'] = '*'
      response.headers['Access-Control-Allow-Methods'] = 'POST, GET, OPTIONS'
    end
    # Use callbacks to share common setup or constraints between actions.
    def set_community_community
      @community_community = Community::Community.find(params[:id])
    end

  def set_area
    if params[:area_id].nil?
      @feature = {:properties => ""}
    else
      area = Town.where(:id => params[:area_id]).first
      @feature = {:properties => {:id => area.id.to_s,
                                  :title => area.title,
                                  :bounds => area.bounds,
                                  :center => area.center
                                 }
                  }
    end
  end

    # Never trust parameters from the scary internet, only allow the white list through.
    def community_community_params
      params.require(:community).permit(:title, :participants, :coordinates, :geometry_type, :agree, :color, :icon, :link)
    end
end
