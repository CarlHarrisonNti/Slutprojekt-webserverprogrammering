require_relative "../handlers.rb"

# Login a user
#
# @param :email [String] the email of the user
# @param :password [String] the password of the user
get "/login" do
  erb :login
end

login_attempts = {}


# Login a user
#
# @param :email [String] the email of the user
# @param :password [String] the password of the user
post "/login" do
  email, password = params[:email], params[:password]
  login_attempts[request.ip] ||= []
  login_attempts[request.ip] << Time.now
  session[:login_attempts] ||= {attempts: 0, time: Time.now}
  if login_attempts[request.ip].size > 3 && Time.now - login_attempts[request.ip].last < 60
    halt 401, "Too many login attempts, try again later."
  end

  result = login_user(email, password)

  unless result
    halt 401, "unauthorized"
  end

  if BCrypt::Password.new(result["Pwd"]) == password
    login_attempts[request.ip] = nil
    session[:user_id], session[:name] = result["id"], result["Name"]
    session[:level] = fetch_user_roles(result["id"]).map {|role| role["Level"]}.max
  else
    halt 401, "unauthorized"
  end
  redirect "/"
end


# Page where you can register a new user
get "/users/new" do
  erb :"users/new"
end

# Register a new user
#
# @param :email [String] the email of the user
# @param :password [String] the password of the user
# @param :username [String] the username of the user
post "/users" do
  email, password, username = params[:email], params[:password], params[:username]
   password_check = verify_password(password)
  if password_check.any? {|_, value| !value }
    session[:error] = password_check
    redirect "/users/new"
  end
  p password
  register_user(email, password, username)
  redirect "/login"
end

# Page where admins can see all users in database
# @see Model#fetch_users
get "/admin/users" do
  @users = fetch_users
  erb :"users/index"
end

# Page where admins can see individual user in database
# @todo use only one query to fetch user and user roles
# @see Model#fetch_user
# @see Model#fetch_user_roles
get "/admin/users/:id" do
  @user = fetch_user(params[:id])
  @user_roles = fetch_user_roles(params[:id])
  p @user_roles
  erb :"users/show"
end

# 
get "/admin/users/:id/edit" do
  @user = fetch_user(params[:id])
  @roles = fetch_roles
  @user_roles = fetch_user_roles(params[:id])
  p @user_roles
  erb :"users/edit"
end

# Page where admins can see all quizzes in database
#
# @see Model#fetch_quizzes
post "/admin/users/:id/update" do
  email, password, username, roles = params[:email], params[:password], params[:username], params[:roles]
  update_user(params[:id], email, password, username)
  update_users_roles(params[:id], roles)
  redirect "/users"
end

# Page where admins can see all quizzes in database
#
# @see Model#fetch_quizzes
post "/admin/users/:id/delete" do
  delete_user(params[:id])
  redirect "/users"
end

# Page where admins can see all quizzes in database
#
# @see Model#fetch_quizzes
get "/logout" do
  session.destroy
  redirect "/"
end
