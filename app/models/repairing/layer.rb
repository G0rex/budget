class Repairing::Layer
  include Mongoid::Document
  include ColumnsList

  belongs_to :town, class_name: 'Town'
  belongs_to :owner, class_name: 'User'
  belongs_to :repairing_category, :class_name => 'Repairing::Category'

  field :title, type: String
  field :description, type: String

  mount_uploader :repairs_file, RepairingRepairUploader
  skip_callback :update, :before, :store_previous_model_for_repairs_file

  has_many :repairs, :class_name => 'Repairing::Repair', autosave: true, :dependent => :destroy

  def self.visible_to user
    files = if user.nil?
      self.where(:owner => nil)
    elsif user.has_role? :admin
      self.all
    else
      self.where(owner: user.id)
    end

    files || []
  end

  def to_geo_json
    geoJson = []
    self.repairs.each { |repair|
      geoJson << Repairing::GeojsonBuilder.build_repair(repair)
    }

    geoJson.compact

  end
end
