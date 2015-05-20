class Documentation::Document
  include Mongoid::Document

  require 'carrierwave/mongoid'


  belongs_to :category, class_name: 'Documentation::Category', autosave: true

  field :title, type: String
  field :description, type: String
  field :issued, type: Date

  field :town, type: String
  field :owner, type: String

  mount_uploader :doc_file, DocumentationUploader
  skip_callback :update, :before, :store_previous_model_for_doc_file

  # validates_presence_of :doc_file, message: 'Файл не може бути пустим'

  # before_save :generate_title

  private

  def generate_title
    self.title = self.doc_file_identifier if self.title.empty?
  end

  private

end
