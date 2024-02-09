require "sinatra"
require "sinatra/reloader"
require "sqlite3"
require "bcrypt"
require 'commonmarker'
require "securerandom"
require_relative "handlers.rb"
require_relative "models.rb"

include Verfiers

SECTIONS = ["instructions", "tests", "solutions"]

enable :sessions

helpers do
  def exercise_color(difficulty)
    case difficulty
    when 1..3
      "green"
    when 4..6
      "yellow"
    when 7..10
      "red"
    end
  end

  def exercise_difficulty(difficulty)
    case difficulty
    when 1..3
      "Easy"
    when 4..6
      "Medium"
    when 7..10
      "Hard"
    end
  end

  def blurb(text)
    text.size > 100 ? text[..100] + "..." : text
  end
end


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

post "/users" do
  email, password, username = params[:email], params[:password], params[:username]
  if session[:error] = verify_password(password)
    redirect "/users/new"
  end
  register_user(email, password, username)
  redirect "/login"
end

get "/users" do
  @users = fetch_users
  erb :"users/index"
end

get "/users/:id" do
  @user = fetch_user(params[:id])
  erb :"users/show"

end

get "/users/:id/edit" do
  @user = fetch_user(params[:id])
  p @user
  erb :"users/edit"
end

post "/users/:id/update" do
  email, password, username = params[:email], params[:password], params[:username]
  update_user(params[:id], email, password, username)
  redirect "/users"
end

post "/users/:id/delete" do
  delete_user(params[:id])
  redirect "/users"
end

get "/logout" do
  session.destroy
  redirect "/"
end

get "/exercises/new" do
  erb :"exercises/new"
end

post "/exercises" do
  name, instructions, difficulty, test_file, icon, blurb = params[:name], params[:instructions], params[:difficulty], params[:test_file], params[:icon], params[:blurb]

  icon_temp_file = icon[:tempfile]
  icon_file_name, extension = icon[:filename].split(".")
  icon_file_name = "#{SecureRandom.uuid}.#{extension}"
  icon_file_path = "./public/icons/exercises/#{icon_file_name}"


  File.write(icon_file_path, icon_temp_file.read)

  test_file_content = File.read(test_file[:tempfile])
  instructions_content = File.read(instructions[:tempfile])

  new_exercise(name, instructions_content, difficulty, test_file_content, "/icons/exercises/#{icon_file_name}", blurb)
  redirect "/exercises"
end

get "/exercises" do
  @exercises = fetch_exercises(10)
  erb :"exercises/index"
end

get "/exercises/:id/tests" do
  @exercise = fetch_exercise(params[:id])
  @content = "<h1>Tests</h1><pre><code class=\"language-ruby\">#{@exercise["Test_File"]}</pre></code>"
  erb :"exercises/show"
end


get "/exercises/:id" do
  @exercise = fetch_exercise(params[:id])
  @content = Commonmarker.to_html(@exercise["Instructions"], options: {
    parse: { smart: true}, render: {unsafe: true}, extension: {header_ids: "markdown ", table: true} })
  erb :"exercises/show"
end

get "/exercises/:id/edit" do
  @exercise = fetch_exercise(params[:id])
  erb :"exercises/edit"
end

post "/exercises/:id/update" do
  name, instructions, difficulty, test_file, icon, blurb = params[:name], params[:instructions], params[:difficulty], params[:test_file], params[:icon], params[:blurb]
  icon_temp_file = icon[:tempfile]
  icon_file_name, extension = icon[:filename].split(".")
  icon_file_name = "#{SecureRandom.uuid}.#{extension}"
  icon_file_path = "./public/icons/exercises/#{icon_file_name}"


  File.write(icon_file_path, icon_temp_file.read)

  test_file_content = File.read(test_file[:tempfile])
  instructions_content = File.read(instructions[:tempfile])
  update_exercise(params[:id], name, instructions_content, difficulty, test_file_content, icon_file_path, blurb)
  redirect "/exercises"
end

post "/exercises/:id/delete" do
  delete_exercise(params[:id])
  redirect "/exercises"
end

get "/roles" do
  @roles = fetch_roles
  erb :"roles/index"
end

get "/roles/new" do
  erb :"roles/new"
end

post "/roles" do
  name, level = params[:name], params[:level]
  new_role(name, level)
  redirect "/roles"
end

get "/roles/:id" do
  @users = fetch_role_and_users(params[:id])
  @role = fetch_role(params[:id])
  p @users
  erb :"roles/show"
end

get "/roles/:id/edit" do
  @role = fetch_role(params[:id])
  erb :"roles/edit"
end

post "/roles/:id/update" do
  name, level = params[:name], params[:level]
  update_role(params[:id], name, level)
  redirect "/roles"
end
