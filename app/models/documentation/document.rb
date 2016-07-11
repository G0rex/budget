require 'file_size_validator'
require 'carrierwave/mongoid'

class Documentation::Document
  include Mongoid::Document

  before_save :generate_title

  skip_callback :update, :before, :store_previous_model_for_doc_file

  scope :get_documents_by_town,-> (town) {where(town: town)}
  scope :unlocked, -> {where({ :locked.in => [false, nil] } )}
  belongs_to :branch, class_name: 'Documentation::Branch'
  belongs_to :town
  belongs_to :owner, class_name: 'User'
  belongs_to :category, class_name: 'Documentation::Category', autosave: true

  field :title, type: String
  field :description, type: String
  field :yearFrom, type: Integer
  field :yearTo, type: Integer
  field :locked, type: Boolean

  mount_uploader :doc_file, DocumentationUploader

  validates_presence_of :doc_file, message: 'Потрібно вибрати Файл'
  validates :doc_file,
            :presence => true,
            :file_size => {
                :maximum => 11.megabytes.to_i
            }

  def check_access(user)
    # this function check access to update or destroy document
    # get one parameter user model
    # return true if user admin
    # return true if user created this document
    # else return false
    user.is_admin? || self.owner.equal?(user)

  end

  def get_years
    years = []
    years << [self.yearFrom] unless self.yearFrom.blank?
    years << self.yearTo unless self.yearFrom == self.yearTo or self.yearTo.blank?
    years.join(' - ')
  end

  def self.get_grouped_documents_for_town(town)
    # get documents by town and not locked and sort by title
    documents = self.get_documents_by_town(town).unlocked.sort_by!{|doc| doc.title ? doc.title : ""  }

    res_hash = {}
    # group documents by year
    documents = documents.group_by(&:yearFrom)

    documents.each do |year,documents_by_year|

      year_documents = documents_by_year.group_by(&:branch_id)

      # transform keys for readeble title
      res_hash.store(year,year_documents.transform_keys{|key| Documentation::Branch.find(key).title })
    end
    res_hash
  end

  private

  def generate_title
    self.title = self.doc_file_identifier unless self.title?
  end

  private

end
