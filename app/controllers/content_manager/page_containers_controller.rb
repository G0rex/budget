class ContentManager::PageContainersController < AdminController
  before_action :set_content_manager_page_container, only: [:show, :edit, :update, :destroy]
  before_action :set_locale_content, only: [:create, :update]

  respond_to :html

  def index
    # @page_containers = ContentManager::PageContainer.get_all_child
    # parent = ContentManager::PageContainer.get_parent_menu(ContentManager::PageContainer::VISUALISATION).first
    @page_containers = ContentManager::PageContainer.get_all_menu
    # binding.pry
    respond_with(@page_containers)
  end

  def show
    respond_with(@page_container)
  end

  def new
    @page_container = ContentManager::PageContainer.new
    respond_with(@page_container)
  end

  def edit
  end

  def create
    binding.pry
    @page_container = ContentManager::PageContainer.new(content_manager_page_container_params)
    @page_container.save
    respond_with(@page_container)
  end

  def update
    binding.pry
    @page_container.update(content_manager_page_container_params)
    respond_with(@page_container)
  end

  def destroy
    @page_container.destroy
    respond_with(@page_container)
  end

  private
    def set_content_manager_page_container
      @page_container = ContentManager::PageContainer.find(params[:id])
    end

    def content_manager_page_container_params
      params.require(:content_manager_page_container).permit(:header,:content,:alias,:p_id,
                                           :uk => [:content,:header],:en => [:content,:header])
    end

    def set_locale_content

    end
end
