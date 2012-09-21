class ActionDispatch::Request

  def to_hash
    path = original_fullpath.split('?').first.split('#').first
    {
    query_parameters: query_parameters,
    scheme: scheme,
    host: host,
    port: port,
    url: original_url,
    path: path,
    fullpath: original_fullpath,
    method: method
    }
  end
  alias_method :to_h, :to_hash

end
