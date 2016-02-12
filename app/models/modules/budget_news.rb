class Modules::BudgetNews
  include Mongoid::Document
  require 'carrierwave/mongoid'

  validates :title,:news_text,:img,:news_date, presence: true
  validates :link, format: { with: /(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?/,
                             message: I18n.t('activerecord.attributes.invalid.link') }

  mount_uploader :img, BudgetNewsImageUploader
  field :title, type: String
  field :news_text, type: String
  field :link, type: String
  field :news_date, type: Date

  def delete_image_file!
    self.remove_img!;
  end

  def news_preview
    news_text[0..200] + '...' ;
  end
  private
    mount_uploader :img, BudgetNewsImageUploader
    skip_callback :update, :before, :store_previous_model_for_img
end
