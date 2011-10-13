
class App < Sinatra::Base

  set :root, SERVER_ROOT_PATH
  set :port, SERVER_CONFIG['port']


  def refresh
    uri = URI.parse(SERVER_CONFIG['tenacy_url'])
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)
    @new_tenacy_url = response["Location"]
  end

  def get_redirected_url
    @new_tenacy_url ||= refresh
  end

  get '/' do
    redirect get_redirected_url
  end

  get '/refresh' do
    refresh
    redirect '/'
  end

  get '/echo/:content' do
    haml :echo, :locals => {:content => params[:content]}
  end
  
end


