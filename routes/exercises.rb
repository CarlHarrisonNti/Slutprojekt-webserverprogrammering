# Page where admins can see all quizzes in database
#
# @see Model#fetch_quizzes
get "/protected/exercises/new" do
  erb :"exercises/new"
end

# Page where admins can see all quizzes in database
#
# @see Model#fetch_quizzes
post "/protected/exercises" do
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

# Page where admins can see all quizzes in database
#
# @see Model#fetch_quizzes
get "/exercises" do
  @exercises = fetch_exercises(10)
  erb :"exercises/index"
end

# Page where admins can see all quizzes in database
#
# @see Model#fetch_quizzes
get "/exercises/:id/tests" do
  @exercise = fetch_exercise(params[:id])
  @content = "<h1>Tests</h1><pre><code class=\"language-ruby\">#{@exercise["Test_File"]}</pre></code>"
  erb :"exercises/show"
end

# Page where admins can see all quizzes in database
#
# @see Model#fetch_quizzes
get "/exercises/:id" do
  @exercise = fetch_exercise(params[:id])
  @content = Commonmarker.to_html(@exercise["Instructions"], options: {
    parse: { smart: true}, render: {unsafe: true}, extension: {header_ids: "markdown ", table: true} })
  erb :"exercises/show"
end

# Page where admins can see all quizzes in database
#
# @see Model#fetch_quizzes
get "/protected/exercises/:id/edit" do
  @exercise = fetch_exercise(params[:id])
  erb :"exercises/edit"
end

# Page where admins can see all quizzes in database
#
# @see Model#fetch_quizzes
post "/protected/exercises/:id/update" do
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

# Page where admins can see all quizzes in database
#
# @see Model#fetch_quizzes
post "/protected/exercises/:id/delete" do
  delete_exercise(params[:id])
  redirect "/exercises"
end
