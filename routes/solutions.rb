# Before-block for adding solutions
# If the user is not logged in, they will be given a 401 Unauthorized
before "/private/exercises/:id/solutions/*" do
  halt 401, "Unauthorized" unless session[:user_id]
end

# Before-block for editing and deleting solutions
# If the user is not the author of the solution or at least level 3 in permissions, they will be given a 401 Unauthorized
before "/private/exercises/:id/solutions/:solution_id/*" do
  author = fetch_solution(params[:solution_id])["user_id"] == session[:user_id]
  unless author || (session[:level] || 0) > 2
    halt 401, "Unauthorized"
  end
end

# Starting page for all solutions
#
# @see Model#fetch_solutions
#
# @param :id [Integer] the id of the exercise
get "/exercises/:id/solutions" do
  @exercise_id = params[:id]
  @solutions = fetch_solutions(@exercise_id)
  erb :"solutions/index"
end

# Page to create a new solution
get "/private/exercises/:id/solutions/new" do
  @id = params[:id]
  erb :"solutions/new"
end

# Route to create a new solution
# It will redirect to /exercises/:id/solutions
#
# @see Model#create_solution
#
# @param :id [Integer] the id of the exercise
# @param :solution_file [File] the file with the solution
post "/private/exercises/:id/solutions" do
  solution_file = params[:solution_file]
  solution_temp_file = solution_file[:tempfile]

  solution = File.read(solution_temp_file)

  exercise_id = params[:id]
  create_solution(session[:user_id], exercise_id, solution)
  redirect "/exercises/#{exercise_id}/solutions"
end

# Route to delete a solution
# It will redirect to /exercises/:id/solutions
#
# @see Model#delete_solution
#
# @param :id [Integer] the id of the exercise
# @param :solution_id [Integer] the id of the solution
post "/private/exercises/:id/solutions/:solution_id/delete" do
  delete_solution(params[:solution_id])
  redirect "/exercises/#{params[:id]}/solutions"
end

# Page for vewing a specific solution
#
# @see Model#fetch_solution_and_users
#
# @param :id [Integer] the id of the exercise
# @param :solution_id [Integer] the id of the solution
get "/exercises/:id/solutions/:solution_id" do
  @solution = fetch_solution_and_users(params[:solution_id])
  erb :"solutions/show"
end

# Page for editing a solution
#
# @see Model#fetch_solution_and_users
#
# @param :id [Integer] the id of the exercise
# @param :solution_id [Integer] the id of the solution
get "/private/exercises/:id/solutions/:solution_id/edit" do
  @solution = fetch_solution_and_users(params[:solution_id])
  @id = params[:id]
  erb :"solutions/edit"
end

# Route to update a solution
# It will redirect to /exercises/:id/solutions
#
# @see Model#update_solution
#
# @param :id [Integer] the id of the exercise
# @param :solution_id [Integer] the id of the solution
post "/private/exercises/:id/solutions/:solution_id/update" do
  solution_file = params[:solution_file]
  if solution_file[:tempfile]
    solution = File.read(solution_file[:tempfile])
  else
    solution = fetch_solution(params[:solution_id])["solution"]
  end

  update_solution(params[:solution_id], solution)
  redirect "/exercises/#{params[:id]}/solutions"
end
