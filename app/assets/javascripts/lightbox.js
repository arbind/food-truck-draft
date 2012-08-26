(function ($, window) {
  var light = $('#light');
  var fade = $('#fade');

  window.hideOverlay = function() {
    light.fadeOut();
    fade.fadeOut();
  };
  window.displayOverlay = function(content){
    alert(1);
    light.html('');
    light.fadeIn();
    fade.fadeIn();
    light.append(content);
  };
}(jQuery, window));
