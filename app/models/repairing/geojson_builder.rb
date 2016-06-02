class Repairing::GeojsonBuilder

  def self.build_repair(repair)
    return if repair[:coordinates].blank? || repair[:coordinates][0].nil?

    if repair[:coordinates][0].is_a?(Array)
      build_repair_path(repair)
    else
      build_repair_point(repair)
    end
  end

  def self.build_repair_point(repair)
    {
        type: "Feature",
        geometry: {
            type: 'Point',
            coordinates: repair[:coordinates]
        },
        properties: {
            repair: "house",
        }.merge(extract_props(repair))
    }
  end

  def self.build_repair_path(repair)
    {
        type: "FeatureCollection",
        properties: {
          id: "#{repair[:id]}"
        }.merge(extract_props(repair)),
        features: [
        {
          type: "Feature",
          geometry: {
            type: 'Point',
            coordinates: repair[:coordinates][0]
          },
          properties: {
            id: "#{repair[:id]}",
            repair: "road",
            route: reduceCoordinatesCount(repair[:coordinates])
          }
        },
        ]
    }

  end

  private

  def self.extract_props repair
    category = Repairing::Category.find(repair.layer[:repairing_category_id]) if repair.layer && repair.layer[:repairing_category_id]

    year = repair[:repair_date] ? repair[:repair_date].year : Date.current.year

    {
        id: "#{repair[:id]}",
        p_c_id: "#{repair.layer[:repairing_category_id] if repair.layer}", #parent_category_id
        # category: "#{Repairing::Category.find(repair[:repairing_category_id]).title if repair[:repairing_category_id]}",
        c_id: "#{repair[:repairing_category_id]}", #category_id
        t_id: "#{repair.layer.town_id if repair.layer}", #town_id
        # obj_owner: "#{repair[:obj_owner]}".gsub('\'', '`'),
        # title: "#{repair[:title]}".gsub('\'', '`'),
        # subject: "#{repair[:subject]}".gsub('\'', '`'),
        # work: "#{repair[:work]}",
        # description: repair[:description],
        address: "#{repair[:address]}".gsub('\'', '`'),
        # amount: "#{repair[:amount]}",
        # repair_date: "#{repair[:repair_date].strftime("%m/%d/%Y") if repair[:repair_date]}",
        year: year,
        # warranty_date: "#{repair[:warranty_date].strftime("%m/%d/%Y") if repair[:warranty_date]}",
        # img: "#{category and category.img ? category.img.icon.url : ''}"
    }
  end

  def self.reduceCoordinatesCount coordinates
    return [] if coordinates.blank?

    n = coordinates.count
    filtered = []
    (0.. n - 2).step(n / 15 + 1) { |i| filtered << coordinates[i] }
    filtered << coordinates[n - 1]
  end

end
