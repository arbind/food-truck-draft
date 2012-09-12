$(function(){

  function show_on_geomap($craft) {
    var mapPins = $craft.data('map-pins') || {};
    if (!mapPins) return
    var geo_point = $craft.data('geo-point');
    if (!geo_point) return;

    marker_info = {
      lat: geo_point.lat,
      lng: geo_point.lng,
      name: 'xyz'
    }
    marker = $('body').drop_geomap_marker(marker_info);
    $craft.data('map-marker', marker);
  };

  function clear_from_geomap($craft) {
    marker = $craft.data('map-marker');
    if (marker) marker.setMap(null);
  }

  function showMap($craft) {
    if( $craft.data('map') ) return; // if map already exists
    var mapPins = $craft.data('map-pins') || {};
    var mapCenter = $craft.data('map-center');
    if (!mapCenter) return
    // +++ calculate center of pins
    init_gmap($craft, mapCenter, mapPins);
  };

  function toggleInfo($craft) {
    var $info = $craft.find('.info');
    if( $info.is(":visible") ) closeInfo($craft); // hide info if it is already shown
    else openInfo($craft); // show info if it is hidden
  }
  function closeInfo($craft) {
    var $info = $craft.find('.info');
    if( $info.is(":visible") ) {
      $info.slideUp();
      clear_from_geomap($craft);
    }
  }
  function openInfo($craft) {
    var $info = $craft.find('.info');
    if( ! $info.is(":visible") ){
      $info.slideDown();
      show_on_geomap($craft);
    }
  }

  $('.craft').live('click.once', function(ev){
    ev.preventDefault();
    ev.stopPropagation();

    var $craft = $(this);
    // toggleInfo($craft);
    openInfo($craft);
  });

  if (1== $('.craft').size) $('.craft').click()

  $('h2.name').live('click.once', function(ev){
    $crafts = $(this).parents('.craft') // should only be one really
    $crafts.each(function(idx, craft){
      toggleInfo($(craft));
    });
  });

})