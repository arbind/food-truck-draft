// for google maps implementtaion: be sure to iclude http://maps.google.com/maps/api/js?sensor=false

/* usage:
  1.  create an html file with a .geomap:
      %html
        %body
          #geomap-wrapper
            .geomap.cut
  2.  $('body').show_geomap();
  3.  marker = {lat: 34.0522342, lng: -118.2436849, name: 'Peet' }
  4. $('body').drop_geomap_marker(marker)
*/

$(function(){

  var GEOMAP = (function ($) {
    var module = {};

    // var maps = {}; // keeps pairs of map: markers{}
    // var markers = {
    //   all: {},
    //   active: {},
    //   dropped: {}    
    // }

    var default_marker_info_window_options =  { maxWidth: 80 };
    var default_geomap_config = {
      zoom: 14,
      scrollwheel:false,
      panControl: false,
      zoomControl: true,
      zoomControlOptions: { style: google.maps.ZoomControlStyle.LARGE },
      mapTypeControl: false,
      mapTypeId: google.maps.MapTypeId.ROADMAP,
    };

// google.maps.Map.prototype.drop_marker(settings) {}
    module.drop_geomap_marker = function(geomap, marker_settings){
      var point=null, marker_info=null, marker=null;
      point = new google.maps.LatLng(marker_settings.lat, marker_settings.lng);
      marker_info = {
        position: point,
        animation: marker_settings.now_active ? google.maps.Animation.BOUNCE : google.maps.Animation.DROP,
        map: geomap,
        title: marker_settings.name, 
        name: marker_settings.name,
        website: marker_settings.website
      }

      geomap.panTo(point); //center the map on the new marker
      marker = new google.maps.Marker(marker_info);

      // see for handlers: https://developers.google.com/maps/documentation/javascript/events
      google.maps.event.addListener(marker, 'click', function() {
        geomap.infoWindow.setContent(marker_settings.content);
        geomap.infoWindow.open(geomap, this);
      });

      // google.maps.event.addListener(marker, 'click', function() {
      //   window.location = this.website;
      // });
      return marker;
    }
    //public methods
    module.init_geomap = function ($container, geomap_center) {
      var $geomap=null, geomap=null, center=null, geo_coordinates=null;

      $geomap = module.$geomap_for_container($container);
      if (!$geomap) return null;

      center = geomap_center;
      if (!center) { // define a default center
        geo_coordinates = $('body').data('geo-coordinates');
        if (geo_coordinates) {
          center = {
            lat: geo_coordinates[0],
            lng: geo_coordinates[1]
          }
        }
        else center = { lat:34.0194543, lng: -118.4911912 } //default center to santa monica ;)
      }

      default_geomap_config.center = new google.maps.LatLng(center.lat, center.lng);

      geomap = new google.maps.Map($geomap.get(0), default_geomap_config);
      if (!geomap) return null;
      $geomap.data('geomap', geomap);

      geomap.infoWindow = new google.maps.InfoWindow(default_marker_info_window_options);

      return geomap
    };

    module.$geomap_for_container = function($container) { 
      var $geomap = $container.find('.geomap');
      if (1 != $geomap.length) return null; // should have exactly 1 place to put the geomap!
      return $geomap;
    };
    module.geomap_for_container = function ($container) { 
      $geomap = this.$geomap_for_container($container);
      if (!$geomap) return null;
      return $geomap.data('geomap');
    };



    // jquery extentions
    $.fn.show_geomap = function(geomap_center) {
      console.log("Showing Map!!!!!!");
      var $container, $geomap=null, geomap=null;
      $container = $(this[0]); // our jQuery element
      geomap = GEOMAP.geomap_for_container($container); // get the geomap if it already existing 
      if (!geomap) geomap = GEOMAP.init_geomap($container, geomap_center); // initialize the geomap if one does not exist
      if (geomap) { // if we have geomap, get its jQuery container and show it
        $geomap = GEOMAP.$geomap_for_container($container);
        $geomap.fadeIn();
      }
      return geomap;
    }

    $.fn.hide_geomap = function() {
      var $container, $geomap=null;
      $container = $(this[0]); // our jQuery element

      geomap = GEOMAP.geomap_for_container($container); // get the geomap if it already existing 
      if (!geomap) return false; // nothing to do if a geomap does not exist

      $geomap = GEOMAP.$geomap_for_container($container);
      $geomap.slideUp();
      return true;
    }

    $.fn.geomap = function() {
      var $container, geomap=null;
      $container = $(this[0]); // our jQuery element
      geomap = GEOMAP.geomap_for_container($container); // get the geomap if it already existing 
      return geomap;
    }

    $.fn.drop_geomap_marker = function(marker_settings){
      var $container, geomap=null;
      $container = $(this[0]); // our jQuery element
      geomap = $container.geomap();
      marker = GEOMAP.drop_geomap_marker (geomap, marker_settings);
      return marker;
    }

    return module;
  }(jQuery));


  $('body').show_geomap();
  // var marker = {lat: 34.0522342, lng: -118.2436849, name: 'Peet', now_active:true }
  // $('body').drop_geomap_marker(marker);
})
  //       infoWindowOptions =  { maxWidth: 80 },
  //   infoWindow = new google.maps.InfoWindow(infoWindowOptions);


  // window.init_gmap = function($container, mapCenter, pins) {
  //   var map=null,
  //       mapElement=null,
  //       infoWindow=null,
  //       infoWindowOptions =  { maxWidth: 80 },
  //       marker=null,
  //       markerInfo=null,
  //       point=null,
  //       centerPoint = new google.maps.LatLng(mapCenter.lat,mapCenter.lng),
  //       options = {
  //         zoom: startZoom,
  //         center: centerPoint,
  //         scrollwheel:false,
  //         panControl: false,
  //         zoomControl: true,
  //         zoomControlOptions: { style: google.maps.ZoomControlStyle.LARGE },
  //         mapTypeControl: false,
  //         mapTypeId: google.maps.MapTypeId.ROADMAP,
  //       };

  //   mapElement = $container.find('.map').get(0);
  //   if (!mapElement) return; // no place to put a map!

  //   map = new google.maps.Map(mapElement, options);
  //   $container.data('map', map);
  //   infoWindow = new google.maps.InfoWindow(infoWindowOptions);
  //   // Ensure 'pins' array is populated with JSon Array of your objects.
  //   $.each(pins, function(id, info){
  //     allMapPins[id] = info;

  //     point = new google.maps.LatLng(allMapPins[id].lat, allMapPins[id].lng);
  //     markerInfo = {
  //       position: point,
  //       animation: allMapPins[id].now_active ? google.maps.Animation.BOUNCE : google.maps.Animation.DROP,
  //       map: map,
  //       title: allMapPins[id].name, 
  //       name: allMapPins[id].name,
  //       website: allMapPins[id].website
  //     }
  //     marker = new google.maps.Marker(markerInfo);

  //     google.maps.event.addListener(marker, 'click', function() {
  //      infoWindow.setContent("<b>"+this.name+"</b><br><a href='" +allMapPins[id].website+ "' target='_blank'>"+allMapPins[id].website+"</a>");
  //      infoWindow.open(map, this);
  //    });

  //    // google.maps.event.addListener(marker, 'click', function() {
  //    //   window.location = this.website;
  //    // });

  //  });
  // }

  // init_map();  
// })
