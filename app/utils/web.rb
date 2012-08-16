class Web

  def self.image_exists?(url)
    image_is_there = false
    begin
      url = URI.parse(url)
      Net::HTTP.start(url.host, url.port) do |http|
      h = http.head(url.request_uri)
        image_is_there = (h.code == "200") ? h['Content-Type'].start_with?('image') : false
      end
    rescue Exception => e
      # bad url
    end
    image_is_there
  end

end