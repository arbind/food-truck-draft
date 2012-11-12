source 'https://rubygems.org'

gem 'rails', '3.2.2'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

# gem 'sqlite3'
gem 'redis'
gem 'mongoid', '2.4.8'
gem 'bson_ext'
# gem 'mongoid'
gem 'newrelic_rpm' #Server Monitoring
group :production do
  gem 'thin'
end


# utils
gem 'sass'
gem 'haml'
gem 'hpricot'
gem 'httparty'
gem 'addressable'
gem 'jquery-rails'

# services
gem 'geocoder'
gem 'yelpster'
gem 'koala' # facebook graph
gem 'twitter'
gem 'tweetstream'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer'
  gem 'uglifier', '>= 1.0.3'
end


gem 'jquery-rails'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

group :test, :development do
  gem 'spork'
  gem 'minitest-rails'
  # gem 'ruby-debug19', :require => 'ruby-debug'
end
