jQuery(function($) {

  // user:scrolled-to-bottom
  // triggered when user scrolls almost(75%) to end of #main-content
  var trigger_user_scrolled_to_bottom = function() {
    var scrollTop = $(this).scrollTop();
    var shownHeight = $(this).innerHeight();
    var totalHeight = $(this)[0].scrollHeight;
    if( (scrollTop + shownHeight) >= 0.75*totalHeight) {
      $('body').trigger('user:scrolled-to-bottom')
    }
  }
  // +++
  $('#main-content').on('scroll', trigger_user_scrolled_to_bottom );
  // $('#main-content').bind('scroll', trigger_user_scrolled_to_bottom);

});
