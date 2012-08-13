class CityState
  include Mongoid::Document
  field :city, type: String
  field :state, type: String
end
