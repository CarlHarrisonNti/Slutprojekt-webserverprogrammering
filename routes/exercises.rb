# Sarting page for all exercises
# It will fetch the first 12 exercises from the database and display them
get "/exercises" do
  @exercises = fetch_exercises(12)
  erb :"exercises/index"
end

# Route for the page where users can see the instructions and tests for an exercise
# It will display the instructions by default
# If the page is "tests" it will display the tests
#
# @see Model#fetch_exercise
#
# @param :id [Integer] the id of the exercise
# @param :page [String] the page to display
get "/exercises/:id" do
  page = params[:page] || "instructions"
  @exercise = fetch_exercise(params[:id])
  case page
  when "instructions"
    @content = Commonmarker.to_html(File.read(@exercise["Instructions"]), options: {
      parse: { smart: true}, render: {unsafe: true}, extension: {header_ids: "markdown ", table: true} })
  else
    @content = "<h1>Tests</h1><pre><code class=\"language-ruby\">#{File.read(@exercise["Test_File"])}</pre></code>"
  end
  erb :"exercises/show"
end

# Page where exercises can be created
# Accessible only by level 3 users
get "/protected/exercises/new" do
  erb :"exercises/new"
end

# Route to create a new exercise
# It will redirect to /exercises
#
# @see Model#new_exercise
#
# @param :name [String] the name of the exercise
# @param :instructions [File] the file with the instructions
# @param :difficulty [Integer] the difficulty of the exercise
# @param :test_file [File] the file with the tests
# @param :icon [File] the icon of the exercise
# @param :blurb [String] the blurb of the exercise
post "/protected/exercises" do
  name, instructions, difficulty, test_file, icon, blurb = params[:name], params[:instructions], params[:difficulty], params[:test_file], params[:icon], params[:blurb]

  icon_temp_file = icon[:tempfile]
  instructions_temp_file = instructions[:tempfile]
  test_file_temp_file = test_file[:tempfile]

  icon_path = "/icons/exercises/#{create_file("icons/exercises", icon_temp_file.read, icon[:filename])}"
  instructions_path = "public/instructions/#{create_file("instructions", instructions_temp_file.read, instructions[:filename])}"
  test_path = "public/tests/#{create_file("tests", test_file_temp_file.read, test_file[:filename])}"

  new_exercise(name, instructions_path, difficulty, test_path, icon_path, blurb)
  redirect "/exercises"
end

# Page to edit an exercise
#
# @see Model#fetch_exercise
get "/protected/exercises/:id/edit" do
  @exercise = fetch_exercise(params[:id])
  p @exercise
  erb :"exercises/edit"
end

# Route to update an exercise
# It will redirect to /exercises
#
# @see Model#update_exercise
#
# @param :id [Integer] the id of the exercise
# @param :name [String] the name of the exercise
# @param :instructions [File] the file with the instructions
# @param :difficulty [Integer] the difficulty of the exercise
# @param :test_file [File] the file with the tests
# @param :icon [File] the icon of the exercise
# @param :blurb [String] the blurb of the exercise
post "/protected/exercises/:id/update" do
  name, instructions, difficulty, test_file, icon, blurb = params[:name], params[:instructions], params[:difficulty], params[:test_file], params[:icon], params[:blurb]

  exercise = fetch_exercise(params[:id])

  if icon
    icon_temp_file = icon[:tempfile]
    icon_path = "/icons/exercises/#{create_file("icons/exercises", icon_temp_file.read, icon[:filename])}"
    delete_files("public#{fetch_exercise(params[:id])["Icon"]}")
  else
    icon_path = exercise["Icon"]
  end

  if instructions
    instructions_temp_file = instructions[:tempfile]
    instructions_path = "public/instructions/#{create_file("instructions", instructions_temp_file.read, instructions[:filename])}"
    delete_files(exercise["Instructions"])
  else
    instructions_path = exercise["Instructions"]
  end

  if test_file
    test_file_temp_file = test_file[:tempfile]
    test_path = "public/tests/#{create_file("tests", test_file_temp_file.read, test_file[:filename])}"
    delete_files(exercise["Test_File"])
  else
    test_path = exercise["Test_File"]
  end

  update_exercise(params[:id], name, instructions_path, difficulty, test_path, icon_path, blurb)
  redirect "/exercises"
end

# Route to delete an exercise
# It will redirect to /exercises
#
# @see Model#delete_exercise
#
# @param :id [Integer] the id of the exercise
post "/protected/exercises/:id/delete" do
  exercise = fetch_exercise(params[:id])
  delete_files(exercise["Instructions"], exercise["Test_File"], "public#{exercise["Icon"]}")
  p "public#{exercise["Icon"]}"
  info = delete_exercise(params[:id])
  redirect "/exercises"
end
