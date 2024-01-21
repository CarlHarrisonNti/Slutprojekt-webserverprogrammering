require "sinatra"
require "sinatra/reloader" if development?

get "/" do
  erb :index
end

get "/login" do
  erb :"users/login"
end