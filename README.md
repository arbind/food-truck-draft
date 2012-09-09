food-truck
==========

Local Area Food Truck Listing

To find potential food trucks near some place:
0. rails c
1. > HoverCraft.scan_for_food_trucks_near_place(@place, @state)
2. > HoverCraft.ready_to_make.each{ |h| h.materialize_craft }
