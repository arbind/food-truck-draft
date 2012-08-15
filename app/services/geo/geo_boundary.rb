class GeoBoundary
  include ToHash
  extend AttrAlias

  # radial boundary
  attr_accessor :radius

  # square boundary
  attr_accessor :ne_geo_point
  attr_alias :ne,                   :ne_geo_point
  attr_alias :north_west_geo_point, :ne_geo_point

  attr_accessor :sw_geo_point
  attr_alias :sw,                     :sw_geo_point
  attr_alias :south_east_geo_point,   :sw_geo_point

  def self.materialize(settings)
    GeoBoundary.new(settings) if (settings[:ne_latitude] or settings[:ne_lat] or settings[:radius])
  end

  def initialize(settings = {})
    self.radius = settings[:radius] if settings[:radius].present?

    if settings[:ne_latitude].present? or settings[:ne_lat].present?
      self.ne = GeoPoint.new({
        lat:        settings[:ne_lat],
        latitude:   settings[:ne_latitude],
        lng:        settings[:ne_lng],
        long:       settings[:ne_long],
        longitude:  settings[:ne_longitude]
        })
    end
    if settings[:sw_latitude].present? or settings[:sw_lat].present?
      self.sw = GeoPoint.new({
        lat:        settings[:sw_lat],
        latitude:   settings[:sw_latitude],
        lng:        settings[:sw_lng],
        long:       settings[:sw_long],
        longitude:  settings[:sw_longitude]
      })
      # default radius to 2
      self.radius = 2 if self.radius.nil? and self.ne.nil?
    end
  end


  def to_hash
    bb = {}
    bb[:radius] = radius if radius.present?

    if ne.present?
      bb[:ne_latitude] = ne.lat 
      bb[:ne_longitude] = ne.lng
    end
    if sw.present?
      bb[:sw_latitude] = sw.lat 
      bb[:sw_longitude] = sw.lng
    end
    bb
  end
end