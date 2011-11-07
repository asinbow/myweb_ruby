module CrossGfw

  def tenacy_url_file
    @tenacy_url_file ||= File.join(ROOT_PATH, SERVER_CONFIG['tenacy_url_file'])
  end

  def tenacy_url_history
    @tenacy_url_history ||= begin
                       if File.exist?(tenacy_url_file)
                         history = YAML.load(File.read(tenacy_url_file))
                         return history if history.is_a?(Array) && history.length>0
                       end
                       [SERVER_CONFIG['tenacy_url']]
                     end
  end

  def try_tenacy_url_history(history)
    history.each do |url|
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Get.new(uri.request_uri)
      response = http.request(request)
      case response.code
      when '200'
        return [false, url]
      when '301'
        return [true, response["Location"]]
      when '404'
        # next
      else
        # unknown code, next
      end
    end
  end

  def tenacy_url_refresh
    history = tenacy_url_history
    redirect, url = try_tenacy_url_history(history)
    if redirect
      history.unshift(url)
      File.open(tenacy_url_file, 'w+') do |f|
        f.write(history.to_yaml)
      end
    end
    url
  end

  def get_tenacy_redirected_url
    @new_tenacy_url ||= tenacy_url_refresh
  end

end
