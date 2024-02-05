require "sinatra"
require "sinatra/reloader"
require "sqlite3"
require "bcrypt"
require 'commonmarker'
require "securerandom"
require_relative "handlers.rb"
require_relative "models.rb"

include Verfiers

enable :sessions

get "/" do
  p session[:user_id]
  erb :index
end

get "/login" do
  erb :"users/login"
end

post "/login" do
  email, password = params[:email], params[:password]
  result = login_user(email, password)
  if result
    session[:user_id], session[:name] = result["id"], result["Name"]
  else
    halt 401, "unauthorized"
  end
  redirect "/"
end

get "/users/new" do
  #session[:error] = nil
  erb :"users/new"
end

post "/users/new" do
  email, password, username = params[:email], params[:password], params[:username]
  if session[:error] = verify_password(password)
    redirect "/users/new"
  end
  register_user(email, password, username)
  redirect "/login"
end

get "/logout" do
  session.destroy
  redirect "/"
end

get "/exercises/new" do
  erb :"exercises/new"
end

post "/exercises/new" do
  name, instructions, difficulty, test_file, icon, blurb = params[:name], params[:instructions], params[:difficulty], params[:test_file], params[:icon], params[:blurb]

  icon_temp_file = icon[:tempfile]
  icon_file_name, extension = icon[:filename].split(".")
  icon_file_name = "#{SecureRandom.uuid}.#{extension}"
  icon_file_path = "./public/icons/exercises/#{icon_file_name}"


  File.write(icon_file_path, icon_temp_file.read)

  test_file_content = File.read(test_file[:tempfile])
  instructions_content = File.read(instructions[:tempfile])

  new_exercise(name, instructions_content, difficulty, test_file_content, "/icons/exercises/#{icon_file_name}", blurb)
  redirect "/exercises/show"
end

get "/exercises/show" do
  @exercises = fetch_exercises(10)
  erb :"exercises/show"
end

get "/exercises/:name" do
  @exercise = fetch_exercise(params[:name])
  @content = Commonmarker.to_html(@exercise["Instructions"], options: {
    parse: { smart: true}, render: {unsafe: true}, extension: {header_ids: "markdown ", table: true} })
  erb :"exercises/index"
end
