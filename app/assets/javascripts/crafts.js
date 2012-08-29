$(function(){

  function showOnMainMap($craft) {
    var mapPins = $craft.data('map-pins') || {};
    if (!mapPins) return

    var mapCenter = $craft.data('map-center');
    if (!mapCenter) return

    // +++ calculate center of pins
    showOnMainMap(mapCenter, mapPins);
  };

  function showMap($craft) {
    if( $craft.data('map') ) return; // if map already exists
    var mapPins = $craft.data('map-pins') || {};
    var mapCenter = $craft.data('map-center');
    if (!mapCenter) return
    // +++ calculate center of pins
    init_gmap($craft, mapCenter, mapPins);
  };

  function toggleInfo($craft) {
    var $info = $craft.find('.info-wrapper');
    if( $info.is(":visible") ) closeInfo($craft); // hide info if it is already shown
    else openInfo($craft); // show info if it is hidden
  }
  function closeInfo($craft) {
    var $info = $craft.find('.info-wrapper');
    var $bio = $craft.find('p.bio');
    if( $info.is(":visible") ) {
      $info.slideUp();
      $bio.slideUp();
    }
  }
  function openInfo($craft) {
    var $info = $craft.find('.info-wrapper');
    var $bio = $craft.find('p.bio');
    if( ! $info.is(":visible") ){
      $info.slideDown();
      $bio.slideDown();
    }
    showMap($craft);
    // showOnMainMap($craft);
  }

  $('.craft').live('click.once', function(ev){
    ev.preventDefault();
    ev.stopPropagation();

    var $craft = $(this);
    // toggleInfo($craft);
    openInfo($craft);
  });

  $('body').live('click.once', function(ev){
    $('.craft').each(function(idx, craft){
      closeInfo($(craft));
    });
  });

  $('h2.name').live('click.once', function(ev){
    $crafts = $(this).parents('.craft') // should only be one really
    $crafts.each(function(idx, craft){
      toggleInfo($(craft));
    });
  });

})