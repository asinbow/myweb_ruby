
class App < Sinatra::Base

  set :root, SERVER_ROOT_PATH
  set :port, SERVER_CONFIG['port']

  def url_file
    @url_file ||= File.join(ROOT_PATH, SERVER_CONFIG['url_file'])
  end

  def url_history
    @url_history ||= begin
                       return YAML.load(File.read(url_file)) if File.exist?(url_file)
                       [SERVER_CONFIG['tenacy_url']]
                     end
  end

  def try_url_history(history)
    history.each do |url|
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Get.new(uri.request_uri)
      response = http.request(request)
      case response.code
      when '200'
        [false, url]
      when '301'
        [true, response["Location"]]
      when '404'
        # next
      else
        # unknown code, next
      end
    end
  end

  def refresh
    history = url_history
    redirect, url = try_url_history(history)
    if redirect
      history.push(url)
      File.open(url_file, 'w+') do |f|
        f.write(history.to_yaml)
      end
    end
    url
  end

  def get_redirected_url
    @new_tenacy_url ||= refresh
  end

  get '/' do
    redirect get_redirected_url
  end

  get '/refresh' do
    redirect refresh
  end

  # simpe echo
  get '/echo/:content' do
    haml :echo, :locals => {:content => params[:content]}
  end

  get '/game' do
    @ws_url ||= "ws://" + SERVERS_CONFIG['web_socket']['domain'] + ':' + SERVERS_CONFIG['web_socket']['port'].to_s + '/'
    haml :game, :locals => {:ws_url => @ws_url}
  end
  
end


