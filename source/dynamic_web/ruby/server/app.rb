
class App < Sinatra::Base

  set :port, 9915

  get '/' do
  'Hello world! I am the sinatra web server'
  end

  get '/echo/:content' do
    haml :echo, :locals => {:content => params[:content]}
  end
  
end


