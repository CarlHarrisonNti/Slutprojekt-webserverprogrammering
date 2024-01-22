require "sinatra"
require "sinatra/reloader" if development?
require "sqlite3"
require "bcrypt"

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
  p email, password
  user = db.execute("SELECT * FROM users WHERE Email = ?", email).first
  p user
  if BCrypt::Password.new(user["Pwd"]) == password
    session[:user_id], session[:name] = user["id"], user["Name"]
  else
    halt 401, "unauthorized"
  end
  redirect "/"
end

get "/users/new" do
  erb :"users/new"
end

post "/users/new" do
  email, password, username = params[:email], params[:password], params[:username]
  db = SQLite3::Database.new("db/main.sqlite")
  db.results_as_hash = true
  db.execute("INSERT INTO users (Email, Pwd, Name) VALUES (?, ?, ?)", email, BCrypt::Password.create(password), username)
  redirect "/login"
end

get "/logout" do
  session.destroy
  redirect "/"
end
