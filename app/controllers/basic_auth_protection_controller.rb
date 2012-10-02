class BasicAuthProtectionController < ApplicationController
  http_basic_authenticate_with name: "fae.food.truck", password: "foodTRUCK2012", except: :sync
end
