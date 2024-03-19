# Starting page for all roles
# It will fetch all roles from the database and display them
#
# @see Model#fetch_roles
get "/admin/roles" do
  @roles = fetch_roles
  erb :"roles/index"
end

# Page where admins can create new roles
get "/admin/roles/new" do
  erb :"roles/new"
end

# Route to create a new role
# It will redirect to /roles
#
# @see Model#new_role
#
# @param :name [String] the name of the role
# @param :level [Integer] the level of the role, needs to be between 1-5
post "/admin/roles" do
  name, level = params[:name], params[:level]
  if 1..5.include?(level)
    new_role(name, level)
    redirect "/roles"
  end

  flash.next[:notice] = "The level has to be between 1 and 5, you wrote #{level}"
  redirect "/admin/roles/new"
end

# Page where admins can see information about a role
# It will fetch all users with the role and display them
#
# @see Model#fetch_role_and_users
# @see Model#fetch_role
#
# @param :id [Integer] the id of the role
get "/admin/roles/:id" do
  @users = fetch_role_and_users(params[:id])
  @role = fetch_role(params[:id])
  erb :"roles/show"
end

# Page where admins can edit a role
#
# @see Model#fetch_role
#
# @param :id [Integer] the id of the role
get "/admin/roles/:id/edit" do
  @role = fetch_role(params[:id])
  erb :"roles/edit"
end

# Route to update a role
# It will redirect to /roles
# @see Model#update_role
#
# @param :id [Integer] the id of the role
# @param :name [String] the name of the role
# @param :level [Integer] the level of the role
post "/admin/roles/:id/update" do
  name, level = params[:name], params[:level]
  update_role(params[:id], name, level)
  redirect "/roles"
end

# Route to delete a role
# It will redirect to /roles
#
# @see Model#delete_role
#
# @param :id [Integer] the id of the role
post "/admin/roles/:id/delete" do
  delete_role(params[:id])
  redirect "/roles"
end
