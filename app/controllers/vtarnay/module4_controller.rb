class Vtarnay::Module4Controller < ApplicationController
  layout 'application_vtarnay'

  before_action :set_budget_file, only: [:show]

  def index
    @budget_files = BudgetFile.all
  end

  def show
    @chart = 3;
  end

  private

  def set_budget_file
    @budget_file = BudgetFile.find(params[:id])
  end
end