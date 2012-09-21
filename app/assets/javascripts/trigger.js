jQuery(function($) {

  // user:scrolled-to-bottom
  // triggered when user scrolls almost(75%) to end of #main-content
  var trigger_user_scrolled = function() {
    // +++ may need to use absolute height value if page is so large, that percentage no longer works
    var scrollTop = $(this).scrollTop();
    var shownHeight = $(this).innerHeight();
    var totalHeight = $(this)[0].scrollHeight;
    var page_percentage = 100* (scrollTop + shownHeight) / totalHeight
    if (page_percentage < 5)
      return
    else if (page_percentage >= 99) 
      $('body').trigger('user:scrolled-to-100%')
    else if (page_percentage >= 90) 
      $('body').trigger('user:scrolled-to-90%')
    else if (page_percentage >= 80) 
      $('body').trigger('user:scrolled-to-80%')
    else if (page_percentage >= 75) 
      $('body').trigger('user:scrolled-to-75%')
    else if (page_percentage >= 70) 
      $('body').trigger('user:scrolled-to-70%')
    else if (page_percentage >= 60) 
      $('body').trigger('user:scrolled-to-60%')
    else if (page_percentage >= 50) 
      $('body').trigger('user:scrolled-to-50%')
    else if (page_percentage >= 40) 
      $('body').trigger('user:scrolled-to-40%')
    else if (page_percentage >= 30) 
      $('body').trigger('user:scrolled-to-30%')
    else if (page_percentage >= 25) 
      $('body').trigger('user:scrolled-to-25%')
    else if (page_percentage >= 20) 
      $('body').trigger('user:scrolled-to-20%')
    else if (page_percentage >= 10) 
      $('body').trigger('user:scrolled-to-10%')
    else (page_percentage >= 5) 
      $('body').trigger('user:scrolled-to-5%')

    // if( (scrollTop + shownHeight) >= 0.75*totalHeight) {
    //   $('body').trigger('user:scrolled-to-75%')
    // }
  }

  // +++
  $('#main-content').on('scroll', trigger_user_scrolled );
  // $('#main-content').bind('scroll', trigger_user_scrolled_to_bottom);



var load_next_page = function(){
  // return if there are no more pages to fetch
  js_var.current_page = js_var.current_page || js_var.page || 1;
  if (js_var.current_page >= js_var.total_pages) {
    //fade in: add a truck we missed:
    return;
  }

  js_var.current_page++;
  // var href = "http://www.food-truck-local.me:3000/?qp=los+angeles%2C+ca&p="+ js_var.current_page
  var endpoint = $.extend({}, js_var.request)
  endpoint.query_parameters == endpoint.query_parameters || {}
  delete endpoint.query_parameters['p'];
  delete endpoint.query_parameters['page'];

  endpoint.query_parameters.page = js_var.current_page
  var href = make_url(endpoint)
  alert(href)
  $('.loadinginprogress').show();
  $.get(href, function(data){
    $('.loadinginprogress').hide();
    $('#craft-list').append($(data).find('#craft-list').children().hide());
    $('#craft-list .section').fadeIn('slow');
  })
}

});
