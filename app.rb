require 'sinatra'
require 'haml'

get '/' do
  'Hello world'
end

get '/echo/:content' do
  haml :echo, :locals => {:content => params[:content]}
end

#set :public_folder, File.dirname(__FILE__) + 'public'
