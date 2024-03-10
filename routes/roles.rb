# Page where admins can see all quizzes in database
#
# @see Model#fetch_quizzes
get "/admin/roles" do
  @roles = fetch_roles
  erb :"roles/index"
end

# Page where admins can see all quizzes in database
#
# @see Model#fetch_quizzes
get "/admin/roles/new" do
  erb :"roles/new"
end

# Page where admins can see all quizzes in database
#
# @see Model#fetch_quizzes
post "/admin/roles" do
  name, level = params[:name], params[:level]
  new_role(name, level)
  redirect "/roles"
end

# Page where admins can see all quizzes in database
#
# @see Model#fetch_quizzes
get "/admin/roles/:id" do
  @users = fetch_role_and_users(params[:id])
  @role = fetch_role(params[:id])
  p @users
  erb :"roles/show"
end

# Page where admins can see all quizzes in database
#
# @see Model#fetch_quizzes
get "/admin/roles/:id/edit" do
  @role = fetch_role(params[:id])
  erb :"roles/edit"
end

# Page where admins can see all quizzes in database
#
# @see Model#fetch_quizzes
post "/admin/roles/:id/update" do
  name, level = params[:name], params[:level]
  update_role(params[:id], name, level)
  redirect "/roles"
end
