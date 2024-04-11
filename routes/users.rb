
# Reset the error message after visit "/users/new"
after "/users/new" do
  session[:error] = nil
end

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
  #session[:login_attempts] ||= { attempts: 0, time: Time.now }
  if login_attempts[request.ip].size > 3 && Time.now - login_attempts[request.ip].last < 60
    halt 401, "Too many login attempts, try again later."
  end

  result = fetch_user(email)

  unless result
    halt 401, "unauthorized"
  end

  if BCrypt::Password.new(result["Pwd"]) == password
    login_attempts[request.ip] = nil
    session[:user_id], session[:name] = result["id"], result["Name"]
    session[:level] = fetch_user_roles(result["id"]).map { |role| role["Level"] }.max
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
  if password_check.any? { |_, value| !value }
    session[:error] = password_check
    redirect "/users/new"
  end
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
# @see Model#fetch_user_from_id
# @see Model#fetch_user_roles
#
# @param :id [Integer] the id of the user
get "/admin/users/:id" do
  @user = fetch_user_from_id(params[:id])
  @user_roles = fetch_user_roles(params[:id])
  erb :"users/show"
end

# Page to edit a user
#
# @see Model#fetch_user_from_id
# @see Model#fetch_roles
# @see Model#fetch_user_roles
#
# @param :id [Integer] the id of the user
get "/admin/users/:id/edit" do
  @user = fetch_user_from_id(params[:id])
  @roles = fetch_roles
  @user_roles = fetch_user_roles(params[:id])
  erb :"users/edit"
end

# Update a user
#
# @see Model#update_user
# @see Model#update_users_roles
#
# @param :id [Integer] the id of the user
# @param :email [String] the email of the user
# @param :password [String] the password of the user
# @param :username [String] the username of the user
# @param :roles [Array] the roles of the user
post "/admin/users/:id/update" do
  email, password, username, roles = params[:email], params[:password], params[:username], params[:roles]
  unless password
    password = fetch_user_from_id(params[:id])["Pwd"]
  end
  update_user(params[:id], email, password, username)
  update_users_roles(params[:id], roles)
  redirect "/admin/users"
end

# Delete a user
# The route will redirect to /users
# @see Model#delete_user
post "/admin/users/:id/delete" do
  delete_user(params[:id])
  redirect "/admin/users"
end

# Logout a user
# The route will redirect to / and destroy the session
get "/logout" do
  session.destroy
  redirect "/"
end
