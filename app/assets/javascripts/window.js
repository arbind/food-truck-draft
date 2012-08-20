(function ($, window) {
  var openWindows = {};
  var newWindowConfig = {top:88, left:88, width:550, height:420};
  closeWindow = function(url) {
    var win = openWindows[url];
    if(win && win.close) win.close();
    openWindows[url] = null;
  };
  openNewWindow = function(url, config){
    var s = "";
    var config = config || this.newWindowConfig;

    if ("string"==typeof config) s = config;
    else if ("object"==typeof config) {
      var first=true;
      for(var key in config) {
        if (!first) s = s + ","
        s = s + " " + key + "="+config[key]
        first = false;
      }
    }
    closeWindow(url);
    win = window.open(url, url, s);
    if (win){
      openWindows[url] = win;
      if (win.focus) win.focus();
    }
  };
}(jQuery, window));
