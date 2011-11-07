
class App < Sinatra::Base
  include CrossGfw

  set :root, SERVER_ROOT_PATH
  set :port, SERVER_CONFIG['port']

  get '/' do
    redirect get_tenacy_redirected_url
  end

  get '/refresh' do
    redirect tenacy_url_refresh
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


