class Widgets::VisifyController < Widgets::WidgetsController
  include ControllerCaching

  before_action :set_locale

  before_action :set_budget_file
  before_action :set_params, :except => [:get_bubbletree_nodedata]

  MAX_NODES_PER_LEVEL = 100

  def visify
  end

  def type
    render :partial => 'widgets/visify/' + params[:type]
  end

  def get_bubbletree_data
    result = use_cache do
      params[:levels] ? levels = params[:levels].split(",") : levels = []
      get_bubble_tree(levels)
    end

    render json: result
  end

  def get_bubblesubtree_with_fact
    taxonomy = visify_params[:taxonomy]
    key = visify_params[:key]

    title =
        if @taxonomy.explanation[taxonomy].nil? or @taxonomy.explanation[taxonomy][key].nil?
          ''
        else
          @taxonomy.explanation[taxonomy][key][:title] || key
        end

    filter = ['fond', taxonomy]

    rows = @taxonomy.get_plan_fact_rows
    tree_rows = @taxonomy.get_subrows(taxonomy, key, filter, rows[:plan]) || {}
    tree_fact_rows = @taxonomy.get_subrows(taxonomy, key, filter, rows[:fact]) || {}

    tree = @taxonomy.create_tree_sceleton tree_rows, filter
    tree_fact = @taxonomy.create_tree_sceleton tree_fact_rows, filter

    tree = create_tree_item_with_fact tree, tree_fact

    render json: get_bubble_tree_item_with_fact(tree, {  'title' => title, 'color' => 'green', 'icon' => '/assets/icons/open_folder.svg' })
  end

  def create_tree_item_with_fact(items, items_fact, key = I18n.t('mongoid.taxonomy.in_total'))
    node = {
        'fact_amount' => items_fact[:amount],
        'amount' => items[:amount],
        'key' => key,
        'taxonomy' => items[:taxonomy]
    }

    children = items.keys.reject{|k| k == :amount || k == :taxonomy }

    unless children.empty?
      node['children'] = []
      children.each { |item_key|
        if items_fact[item_key].nil?
          items_fact[item_key] = {}
          items_fact[item_key][:amount] = 0
        end
        node['children'] << create_tree_item_with_fact(items[item_key], items_fact[item_key], item_key)
      }
    end
    node
  end

  def get_bubblesubtree
    # http://localhost:3000/widgets/visify/get_bubblesubtree/551e4e197562751064010000/2015/0/kvk/10:48380

    taxonomy = visify_params[:taxonomy]
    key = visify_params[:key]

    title =
        if @taxonomy.explanation[taxonomy].nil? or @taxonomy.explanation[taxonomy][key].nil?
          ''
        else
          @taxonomy.explanation[taxonomy][key][:title] || key
        end

    filter = ['fond', taxonomy]
    tree = @budget_file.get_subtree(taxonomy, key, filter) || {}

    render json: get_bubble_tree_item(tree, {  'title' => title, 'color' => 'green', 'icon' => '/assets/icons/open_folder.svg' })
  end

  def get_bubbletree_nodedata
    taxonomy = visify_params[:taxonomy]
    key = visify_params[:key]

    description =
      if @taxonomy.explanation[taxonomy].nil? or @taxonomy.explanation[taxonomy][key].nil?
        ''
      else
        @taxonomy.explanation[taxonomy][key][:description]
      end

    render json: { 'description' => description }
  end

  def get_attachments
    render json: { 'attachments' => @taxonomy.taxonomy_attachments }
  end

  def get_visify_level
    taxonomy = visify_params[:taxonomy]

    render json: @taxonomy.get_level(taxonomy)
  end

  private

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def get_bubble_tree levels
    tree = @budget_file.get_tree levels
    return if tree.nil?

    get_bubble_tree_item(tree, { 'color' => 'green', 'icon' => '/assets/icons/pig.svg' })
  end

  def get_bubble_tree_item(item, info)

    if (item['children'] && item['children'].count == 1 && @taxonomy.is_a?(TaxonomyRot))
      item = item['children'][0]
    end

    node = {
        'amount' => item['amount'],
        'label' => item['key'],
        'key' => item['key'],
        'taxonomy' => item['taxonomy']
    }



    if info
      node['label'] = info['title'] unless info['title'].nil?
      node['icon'] = info['icon'] unless info['icon'].nil? or info['icon'].empty?
      node['color'] = info['color'] unless info['color'].nil? or info['color'].empty?
      # node['description'] = info['description'] unless info['description'].nil? or info['description'].empty?
    end

    # colors = ['#1f77b4','#ff7f0e','#2ca02c','#d62728','#9467bd','#8c564b','#e377c2','#7f7f7f','#bcbd22','#17becf']
    if item['children'].nil?
      # color = colors.sample
      node['color'] = '#a8bccc'
    elsif node['color'].nil?
      # node['color'] = '#265f91'
    end

    child_count = if item['children'].nil?
                    0
                  else
                    item['children'].reject{|c| ((c['amount'][@sel_year][@sel_month].to_i rescue 0) || 0) == 0 }.length
                  end

    unless item['children'].nil?
      node['children'] = []

      item['children'].each { |child_node|
        explanation = ( @taxonomy.explanation[child_node['taxonomy']][child_node['key']] rescue {} )


        ti = get_bubble_tree_item(child_node, explanation) # if child_node[:amount].abs > cut_amount
        unless ti.nil?
          # if node['children'].length >= MAX_NODES_PER_LEVEL && child_count > MAX_NODES_PER_LEVEL + 2
          #   if node['children'][MAX_NODES_PER_LEVEL].nil?
          #     node['children'][MAX_NODES_PER_LEVEL] =
          #         { 'label' => I18n.t('aggregated'),
          #           'color' => 'green',
          #           'icon' => 'fa-folder-open-o'
          #         }
          #     node['children'][MAX_NODES_PER_LEVEL]['children'] = []
          #   end
          #
          #   node['children'][MAX_NODES_PER_LEVEL]['amount'] = {} if node['children'][MAX_NODES_PER_LEVEL]['amount'].nil?
          #   ti['amount'].each { |year, months|
          #     node['children'][MAX_NODES_PER_LEVEL]['amount'][year] = {} if node['children'][MAX_NODES_PER_LEVEL]['amount'][year].nil?
          #     months.each { |month, amount|
          #       node['children'][MAX_NODES_PER_LEVEL]['amount'][year][month] = 0 if node['children'][MAX_NODES_PER_LEVEL]['amount'][year][month].nil?
          #       node['children'][MAX_NODES_PER_LEVEL]['amount'][year][month] += amount
          #     }
          #   }
          #   node['children'][MAX_NODES_PER_LEVEL]['children'] << ti
          # else
            node['children'] << ti
          # end
        end
      }
    end
    node unless node['amount'].nil?
  end

  def set_budget_file
    @budget_file = BudgetFile.where(:id => visify_params[:file_id]).first
    @taxonomy = Taxonomy.where(:id => visify_params[:file_id]).first || @budget_file.taxonomy

    if @budget_file.nil?
      @budget_file = @taxonomy
      @types_count = @taxonomy.budget_files.group_by{|f| f.data_type}.count
    else
      @data_type = @budget_file.data_type
      @types_count = 1
    end
    @data_type = 'plan' if @data_type.blank?

    @levels = @taxonomy.columns.keys
    @file_type = @taxonomy._type
  end

  def set_params
    @sel_year = '0'
    @sel_month = '0'

    @range = {}
    range = {}
    @budget_file.get_range.each{ |item| item.each{ |k, v| range[k] = v } }
    @range = range.sort_by{|k,v| k.to_i}

    @sel_year = visify_params[:year] || @range.last[0]
    @sel_month = visify_params[:month] || @range.last[1].first

    @fond_codes = Taxonomy.fond_codes(params['locale'] || 'uk')

  rescue => e
    logger.error "Не вдалося створити візуалізацію. Перевірте коректність змісту завантаженого файлу => #{e}"
  end

  def visify_params
    params.permit(:file_id, :year, :month, :key, :taxonomy, :levels)
  end

end
