$(document).ready(function(){
  $('body').pageScroller({ 
    navigation: '#nav',
    scrollOffset: -150,
    animationType: 'easeInOutExpo'
  });
});

// view-source:http://pagescroller.com/
/*  AVAILABLE OPTIONS (Page Scroller PRO):
   *  
   *  animationSpeed        speed of page transition (milliseconds)
   *  animationType       animation type during page transition - default: 'swing'
   *  keyboardControl       hijacks keyboard arrows for page navigation
   *  deepLink          appends hash tag to window URL when navigating, link-back
   *  sectionClass        class used to determine page sections
   *  navigation          array of label names, array of anchors (jQuery selector)
   *  navigationClass       alters skin type 'standardNav light' by default
   *                skins:  'iconNav left', 'standardNav left', 'topNav','dropdownNav'
   *                    'slideNav left', 'dotNav left', 'arrows'
   *  navigationLabel       tab label for drop down & slide out skins
   *  linkClass         unique class for page scroller navigation links
   *  scrollOffset        distance offset of scroll target
   *  HTML5mode         uses <section> and <nav> elements
   *  animationBefore       callback: assign a function before animation
   *  animationComplete     callback: assign a function after animation
   *  onChange          callback: assign a function for when section changes
   *  
  */
