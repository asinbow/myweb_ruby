
class App < Sinatra::Base

  set :port, 80

  get '/' do
  'Hello world'
  end

  get '/echo/:content' do
    haml :echo, :locals => {:content => params[:content]}
  end
  
end


