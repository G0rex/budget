class FzBudgetFilesController < ApplicationController

  include BudgetFileUpload

  layout 'application_admin'

  include BudgetFileUpload

  def new
    def get_taxonomies_list model
      taxs = model.owned_by(current_user.town)
      tax_id = taxs.last.id unless taxs.blank?
      [taxs, tax_id]
    end

    @fz_file = FzBudgetFile.new

    @taxonomies_rot, @current_taxonomy_rot_id = get_taxonomies_list(TaxonomyRot)
    @taxonomies_rov, @current_taxonomy_rov_id = get_taxonomies_list(TaxonomyRov)
  end

  def create
    taxonomy_rot = Taxonomy.find_by(:id => params[:budget_file_taxonomy_rot])
    taxonomy_rov = Taxonomy.find_by(:id => params[:budget_file_taxonomy_rov])

    raise 'Не вказано код місцевого бюджету. Необхідно налаштувати параметри візуалізації' if taxonomy_rot.kmb.blank? || taxonomy_rov.kmb.blank?

    fzbudgetfile_params[:path].each do |uploaded|
      file = upload_file uploaded, uploaded.original_filename

      fz_file = FzBudgetFile.new
      fz_file.title = file[:name]
      fz_file.path = file[:path].to_s

      def remove_old_fz user_name, file_name
        BudgetFile.where(:author => user_name, :name => file_name).destroy_all
      end

      remove_old_fz(current_user.email, file[:name])


#      remove_annual_rows = ->(rows) do
#        rows.each do |row|
#          row['m0'] = (1..12).map { |i| row["m#{i}"].to_f }.sum
#        end

#        return rows.reject do |row|
#          row['m0'] != 0 and row['m0'] == row['m1'] and rows.detect {|f| f['cf'] == 7 and f['m0'] != f['m1'] and row['fcode'] == f['fcode'] and row['ecode'] == f['ecode'] and row['kvk'] == f['kvk']}
#        end
#      end

#      rows = remove_annual_rows.call(read_table_from_file(fz_file.path)[:rows])
      rows = read_table_from_file(fz_file.path)[:rows]

      fz_file.rot_file = BudgetFileRotFz.new(title: fz_file.title + ' - Доходи', taxonomy: taxonomy_rot) if taxonomy_rot
      fz_file.rov_file = BudgetFileRovFz.new(title: fz_file.title + ' - Видатки', taxonomy: taxonomy_rov) if taxonomy_rov

      [fz_file.rot_file, fz_file.rov_file].compact.each do |budget_file|
        budget_file.data_type = :plan
        budget_file.author = current_user.email
        budget_file.name = file[:name]
        budget_file.import rows
      end

      fz_file.save!
    end

    respond_to do |format|
      format.html { redirect_to budget_files_path, notice: t('budget_files_controller.load_success') }
      format.json { render :show, status: :created, location: @vz_file }
    end

  rescue => e
    message = "Не вдалося завантажити файл : #{e}"
    respond_to do |format|
      format.html { redirect_to :back, alert:  message }
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def fzbudgetfile_params
    params.require(params[:controller].singularize).permit(:title, :data_type, :taxonomy_rot, :taxonomy_rov, :path => [])
  end

end
