FoodTruck::Application.routes.draw do


  # resources :nizers

  # resources :categories
  # resources :meals
  # resources :cuisines

  # resources :countries
  # resources :states
  # resources :cities
  # resources :metros
  # resources :counties
  # resources :neighborhods
  # resources :colleges

  resources :crafts

  get  'hover_crafts/scan_place', to: 'hover_crafts#new_scan_place', as: :hover_craft_new_scan_place
  post 'hover_crafts/scan_place', to: 'hover_crafts#start_scanning_place', as: :hover_craft_start_scanning_place
  resources :hover_crafts

  # root to: 'root#route_subdomain', constraints: lambda {|req| tokens =req.host.downcase.split('.'); (3==tokens.size && 'www'!=tokens.first) ? true : false }
  root to: 'root#index'
 
  # root to: 'root#index', as: :root

  get 'load_url', to: 'root#load_url'

  scope "/", controller: :food_truck do
    get "index", as: :home_page
    get ":name", to: :lookup, as: :lookup
  end

  


  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # See how all your routes lay out with "rake routes"

end
