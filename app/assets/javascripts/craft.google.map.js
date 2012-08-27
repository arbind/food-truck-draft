// iclude http://maps.google.com/maps/api/js?sensor=false
var startZoom = 14;
var allMapPins = {}

function init_gmap($container, mapCenter, pins) {
  var map=null,
      mapElement=null,
      infoWindow=null,
      infoWindowOptions =  { maxWidth: 80 },
      marker=null,
      markerInfo=null,
      point=null,
      centerPoint = new google.maps.LatLng(mapCenter.lat,mapCenter.lng),
      options = {
        zoom: startZoom,
        center: centerPoint,
        scrollwheel:false,
        panControl: false,
        zoomControl: true,
        zoomControlOptions: { style: google.maps.ZoomControlStyle.LARGE },
        mapTypeControl: false,
        mapTypeId: google.maps.MapTypeId.ROADMAP,
      };

  mapElement = $container.find('.map').get(0);
  if (!mapElement) return; // no place to put a map!

  map = new google.maps.Map(mapElement, options);
  $container.data('map', map);
  infoWindow = new google.maps.InfoWindow(infoWindowOptions);
  // Ensure 'pins' array is populated with JSon Array of your objects.
  $.each(pins, function(id, info){
    allMapPins[id] = info;

    point = new google.maps.LatLng(allMapPins[id].lat, allMapPins[id].lng);
    markerInfo = {
      position: point,
      animation: allMapPins[id].now_active ? google.maps.Animation.BOUNCE : google.maps.Animation.DROP,
      map: map,
      title: allMapPins[id].name, 
      name: allMapPins[id].name,
      website: allMapPins[id].website
    }
    marker = new google.maps.Marker(markerInfo);

    google.maps.event.addListener(marker, 'click', function() {
     infoWindow.setContent("<b>"+this.name+"</b><br><a href='" +allMapPins[id].website+ "' target='_blank'>"+allMapPins[id].website+"</a>");
     infoWindow.open(map, this);
   });

   // google.maps.event.addListener(marker, 'click', function() {
   //   window.location = this.website;
   // });

 });
}
