$(function(){

  function showMap($craft) {
    init_gmap(34.023347, -118.2867908, $craft);
  };

  function toggleInfo($craft) {
    var $info = $craft.find('.info-wrapper');
    if( $info.is(":visible") ) closeInfo($craft); // hide info if it is already shown
    else openInfo($craft); // show info if it is hidden
  }
  function closeInfo($craft) {
    var $info = $craft.find('.info-wrapper');
    if( $info.is(":visible") ) $info.slideUp();
  }
  function openInfo($craft) {
    var $info = $craft.find('.info-wrapper');
    if( ! $info.is(":visible") )$info.slideDown();
    showMap($craft);
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