var make_url = function (url_components) {
  var url, scheme, host, port, path, query_parameters;

  if (url_components['scheme']) 
    scheme = url_components['scheme'] + '://'
  else
    scheme = '//'

  host = url_components['host']

  if (80 != url_components['port'])
    port = ':' + url_components['port']
  else 
    port = ''

  if (url_components['path']) 
    path = url_components['path']
  else
    path = '/'
  if (url_components['query_parameters'])
    query_parameters = '?' + $.param(url_components['query_parameters']);
  else 
    query_parameters = ''

  url = scheme + host + port + path + query_parameters;
  return url
}

var make_url_for_next_page = function(){
  js_var.current_page = js_var.current_page || js_var.page || 1;
  if (js_var.current_page >= js_var.total_pages)
    return null;

  var endpoint = $.extend({}, js_var.request)
  endpoint.query_parameters == endpoint.query_parameters || {}
  delete endpoint.query_parameters['p'];
  delete endpoint.query_parameters['page'];

  endpoint.query_parameters.page = js_var.current_page + 1
  var href = make_url(endpoint)
  return href
}
