
class App < Sinatra::Base

  get '/' do
  'Hello world'
  end

  get '/echo/:content' do
    haml :echo, :locals => {:content => params[:content]}
  end
  
end


