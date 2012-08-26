// iclude http://maps.google.com/maps/api/js?sensor=false
var startZoom = 9;
var map;
var markers = {};

function init_gmap(centerLatitude, centerLongitude, $container) {

 if( $container.data('map') ) return; // if map already exists

 var options = {zoom: startZoom,
 center: new google.maps.LatLng(centerLatitude,centerLongitude),
 zoomControl: true,
 panControl: true,
 mapTypeId: google.maps.MapTypeId.ROADMAP };

 mapElement = $container.find('.map').get(0);
 map = new google.maps.Map(mapElement, options);
 $container.data('map', map);
 var infoWindow = new google.maps.InfoWindow({ maxWidth: 100 });
 // Ensure 'markers' array is populated with JSon Array of your objects.
 for(id in markers) {
   var loc = new google.maps.LatLng(markers[id].latitude, markers[id].longitude);
   var marker = new google.maps.Marker({ position: loc,
                                map: map,
                                name: markers[id].name,
                                subdomain: markers[id].subdomain
                });

   google.maps.event.addListener(marker, 'mouseover', function() {
     infoWindow.setContent(this.name);
     infoWindow.open(map, this);
   });

   google.maps.event.addListener(marker, 'click', function() {
     window.location = 'http://' + this.subdomain;
   });
 }
}
