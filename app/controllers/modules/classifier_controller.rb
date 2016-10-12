module Modules
  class ClassifierController < ApplicationController
    before_action :town, only: [:e_data, :search_data, :advanced_search, :by_type]
    respond_to :html, :js, :json
    # layout 'visify'

    def search_data
      @items = items_by_koatuu.only(:pnaz, :edrpou).to_a
      respond_with(@items)
    end

    def iframe
      # access from iframe
      @items = items_by_koatuu.only(:pnaz, :edrpou).to_a
      respond_to do |format|
        format.html { render 'modules/classifier/search_data' }
      end
    end

    def direct_link
      # access from direct link
      @items = items_by_koatuu.only(:pnaz, :edrpou).to_a
      respond_to do |format|
        format.html { render 'modules/classifier/share_search' }
      end
    end

    def search_e_data
      data = sort_e_data
      @payments = Kaminari.paginate_array(data).page(params[:page]).per(10) unless data.nil?
      # this variable are using for chart
      @receivers = ExternalApi::most_received(params['payers_edrpous'], params['recipt_edrpous']).first(10)

      # switch between '*.js.erb' depend on sorting params
      if params['sort_col'].blank?
        # respond_with(@payments, @receivers)
        respond_to do |format|
          # TODO should be rewrite using as :template
          format.html {render 'modules/classifier/_search_e_data', layout: 'visify'}
          format.js { render 'modules/classifier/search_e_data' }
          format.json { render json: @payments }
          format.csv { send_data Modules::Classifier.to_csv(data) }
        end
      else
        respond_to do |format|
        format.js { render 'modules/classifier/sort_e_data' }
        end
      end
    end

    def advanced_search
      @types_payer = Modules::ClassifierType.where(payer: true).all
      @types_receipt = Modules::ClassifierType.where(receipt: true).all
      @items = items_by_koatuu.only(:pnaz, :edrpou).to_a.sort_by! { |hash| hash.pnaz }
      respond_with(@types, @items)
    end

    def by_type
      # add 'where' filter if type was select
      @items = (params["type"].blank? ? items_by_koatuu : items_by_koatuu.where(:k_form.in=> Modules::ClassifierType.find(params["type"])["code"])).to_a.sort_by! do |hash|
        if params['sort_column'].blank?
          # use default sorting if sorting params empty
          hash.pnaz
        else
          hash[params['sort_column']]
        end
      end
      @items = Kaminari.paginate_array(@items).page(params[:page]).per(10)
      @items.reverse! unless params['sort_column'].blank? || params['sort_direction'].eql?('asc')
      @role = params["role"]
      # switch between '*.js.erb' depend on sorting params
      if params['sort_column'].blank?
        respond_with(@items)
      else
        respond_to do |format|
          format.js { render 'modules/classifier/by_type_results' }
        end
      end
    end

    # TODO: Do refactor in future
    def import_dbf
      unless params[:file_name].nil?
        data = File.open(params[:file_name].tempfile)
        widgets = DBF::Table.new(data, nil, 'cp866')
        #TODO: Do refactor in future
        i = 0
        types = Modules::ClassifierType.all_types
        #binding.pry

        widgets.each do |widget|

          if i < 5
            attributes = widget.attributes
            web = Modules::Classifier.new
            if(web.fill_params attributes, types)
              # i=i+1
            end
          end
        end
      end
    end

    # TODO: Do refactor in future
    def all_classifier
      # @towns = Rails.cache.fetch("all_classifier", expiries: 1.month) do
      #   Modules::Classifier.all.group_by{|classf| classf.town_id}.transform_keys do |key|
      #     town = Town.where(id: key).first
      #     town_name = town.title unless town.nil?
      #     town_koatuu = town.koatuu unless town.nil?
      #     #binding.pry
      #     [key,town_name, town_koatuu]
      #   end
      # end
      @classf= Modules::Classifier.where(town:nil).all
      respond_to do |format|
        format.html { send_data @classf.to_csv, filename: "users-#{Date.today}.csv" }
        format.csv { send_data @classf.to_csv, filename: "users-#{Date.today}.csv" }
      end
      # classf.save
    end


    # TODO: Do refactor in future
    def all_classifier_region
      @regions = Rails.cache.fetch("all_classifier_region", expiries: 1.month) do
        Modules::Classifier.all.group_by{|classf| classf.sk_ter}
      end
      # @classf= Modules::Classifier.where(town:nil).all
      # respond_to do |format|
      #   format.html { send_data @classf.to_csv, filename: "users-#{Date.today}.csv" }
      #   format.csv { send_data @classf.to_csv, filename: "users-#{Date.today}.csv" }
      # end
      # classf.save
    end

    private

    def sort_e_data
      # Data
      payments_data = ExternalApi::e_data_payments(
          params['payers_edrpous'],
          params['recipt_edrpous'],
          (params['period'].split('/').first unless params['period'].blank?),
          (params['period'].split('/').last unless params['period'].blank?)
      )
      # Sort data
      sort_col = params['sort_col'].blank? ? 'trans_date' : params['sort_col']
      unless payments_data.nil?
        payments_data.sort_by! do |hash|
          if sort_col.eql?('amount')
            hash[sort_col.to_s].to_f
          else
            hash[sort_col.to_s]
          end
        end
        payments_data.reverse! unless params['sort_dir'].eql?('asc')
      end
      # Results
      payments_data
    end

    def items_by_koatuu
      #binding.pry
      Modules::Classifier.by_koatuu(town.koatuu, town.koatuu[2..10].eql?('00000000') ? 2 : 5)
    end

    def town
      @town = Town.find(params[:town_id])
    end
  end
end
#
# if (barChart) {
#     barChart.destroy();
# $('#most-received').hide();
# }
#
# <%- unless params['payers_edrpous'].blank? || @receivers.size < 5 %>
#   $('#most-received').show();
#
#   var label = [];
#   var data_set = [];
#   <%- @receivers.each do |payment| %>
#     label.push('<%= payment[:name].html_safe %>');
#     data_set.push(<%= '%.2f' % payment[:val] %>);
# <%- end %>
#
#   // prepare chart options and datasets
#   var data = {
#     labels: label,
#     datasets: [
#       {
#         label: I18n.t('modules.classifier.chart.total'),
#         backgroundColor: 'rgba(98, 141, 182, 1)',
#         hoverBackgroundColor: 'rgba(255, 211, 4, 1)',
#         data: data_set
#       }
#     ]
#   };
#   var ctx = $('#barChart').get(0);
# //  var ctx = $('#barChart');
#   var options = {
#     maintainAspectRatio: false,
#     tooltips: {
#       backgroundColor: 'rgba(12, 34, 49, 1)'
#     },
#     legend: {
#       display: false
#     },
#     scales: {
#       yAxes: [{
#         gridLines: {
#           display: false
#         },
#         barPercentage: 0.7,
#         ticks: {
#           fontSize: $(window).width() >= 1024 ? 12 : 8,
#           autoSkip: false,
#           maxRotation: 0
#         }
#       }],
#       xAxes: [{
#         type: 'logarithmic',
#         position: 'bottom',
#         gridLines: {
#           drawBorder: false,
#           display: false
#         },
#         ticks: {
#           min: data_set[data_set.length-1] / 2,
#     max: data_set[0] * 2,
#     display: false
# }
# }]
# },
#     animation: {
#         duration: 2000,
#         easing: 'easeInOutSine',
#         onProgress: function () {
#           // render the value of the chart above the bar
#           var ctx = this.chart.ctx;
#           ctx.font = Chart.helpers.fontString(
#           $(window).width() >= 1024 ? Chart.defaults.global.defaultFontSize : Chart.defaults.global.defaultFontSize-4,
#               'normal',
#               Chart.defaults.global.defaultFontFamily
#           );
#           ctx.fillStyle = this.chart.config.options.defaultFontColor;
#           ctx.textAlign = 'left';
#           ctx.textBaseline = 'top';
#           this.data.datasets.forEach(function (dataset) {
#             for (var i = 0; i < dataset.data.length; i++) {
#                 var model = dataset._meta[Object.keys(dataset._meta)[0]].data[i]._model;
#             ctx.fillText(parseInt(dataset.data[i] / 1000) + ' тис. грн.', model.x + 5, model.y - 5);
#             }
#             });
#             }
#             }
#             };
#
#             // create and draw the chart
#             var barChart = new Chart(ctx, {
#                 type: 'horizontalBar',
#                 data: data,
#                 options: options
#             });
#
#             <%- end %>
