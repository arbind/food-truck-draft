class FacebookCraft
  include Mongoid::Document
  include Mongoid::Timestamps

  field :facebook_id
  field :likes
  field :talking_about_count

  field :name
  field :first_name
  field :last_name
  field :username
  field :gender
  field :locale
  field :is_published
  field :website
  field :about
  field :location
  field :parking
  field :public_transit
  field :payment_options
  field :culinary_team
  field :general_manager
  field :restaurant_services
  field :restaurant_specialties
  field :category
  field :link
  field :cover

  def self.materialize_from_facebook(user_hash)
puts "11 #{user_hash[:id]}"
puts "11 #{user_hash['id']}"
    facebook_id = user_hash.delete('id')
puts "12 #{user_hash[:id]}"
puts "12 #{user_hash['id']}"
    account = FacebookCraft.find_or_initialize_by(facebook_id: facebook_id)
puts "13 #{account.id}"
puts "13 #{account.facebook_id}"

    #remove unneeded atts
    # image_url = user_hash[:profile_image_url]
    # user_hash[:profile_image_url_bigger] = image_url # default

    account.update_attributes(user_hash)
puts 14
    account

  end

  def self.pull(user_or_page_name) FacebookService.pull(user_or_page_name) end

  def pull() FacebookCraft::pull(facebook_id) end
  
end
