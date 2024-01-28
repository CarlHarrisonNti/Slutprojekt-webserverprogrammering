require "sinatra"
require "sinatra/reloader"
require "sqlite3"
require "bcrypt"
require 'commonmarker'
require_relative "handlers.rb"

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
  db = SQLite3::Database.new("db/main.sqlite")
  db.results_as_hash = true
  user = db.execute("SELECT * FROM users WHERE Email = ?", email).first
  if BCrypt::Password.new(user["Pwd"]) == password
    session[:user_id], session[:name] = user["id"], user["Name"]
  else
    halt 401, "unauthorized"
  end
  redirect "/"
end

get "/users/new" do
  p params
  erb :"users/new"
end

post "/users/new" do
  email, password, username = params[:email], params[:password], params[:username]
  db = SQLite3::Database.new("db/main.sqlite")
  db.results_as_hash = true
  if @message = verify_password(password)
    redirect "/users/new"
  end
  db.execute("INSERT INTO users (Email, Pwd, Name) VALUES (?, ?, ?)", email, BCrypt::Password.create(password), username)
  redirect "/login"
end

get "/logout" do
  session.destroy
  redirect "/"
end

get "/exercises/show" do
  @exercises = [{name: "Diamond", image: "https://assets.exercism.org/exercises/diamond.svg", stub: "Lorem ipsum dolor sit amet consectetur adipisicing elit. Officia, nam. Vel delectus, dicta rem laudantium magnam."},
                {name: "Bob", image: "https://assets.exercism.org/exercises/bob.svg", stub: "Lorem ipsum dolor sit amet consectetur adipisicing elit. Officia, nam. Vel delectus, dicta rem laudantium magnam.",},
                {name: "Beer Song", image: "https://assets.exercism.org/exercises/beer-song.svg", stub: "Lorem ipsum dolor sit amet consectetur adipisicing elit. Officia, nam. Vel delectus, dicta rem laudantium magnam."},
                {name: "Leap", image: "https://assets.exercism.org/exercises/leap.svg", stub: "Lorem ipsum dolor sit amet consectetur adipisicing elit. Officia, nam. Vel delectus, dicta rem laudantium magnam."}]
  erb :"exercises/show"
end

get "/exercises/:name" do
  @exercise = {name: "Diamond", image: "https://assets.exercism.org/exercises/diamond.svg", stub: "Lorem ipsum dolor sit amet consectetur adipisicing elit. Officia, nam. Vel delectus, dicta rem laudantium magnam."}
  p Commonmarker.to_html(File.read("./data.md"), options: {
    parse: { smart: true }})
  erb :"exercises/index"
end
