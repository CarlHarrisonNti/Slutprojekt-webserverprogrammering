require 'sqlite3'

module Modules
  # Connect to the database
  # @return [SQLite3::Database] the database
  def connect_to_db()
    db = SQLite3::Database.new("db/main.sqlite")
    db.results_as_hash = true
    db
  end

  # Register a new user
  # @param email [String] the email of the user
  # @param password [String] the password of the user
  # @param username [String] the username of the user
  # @return [nil]
  def register_user(email, password, username)
    db = connect_to_db()
    db.execute("INSERT INTO users (Email, Pwd, Name) VALUES (?, ?, ?)", email, BCrypt::Password.create(password),
               username)
  end

  # Fetch all users
  # @return [Array<Hash>] all users
  def fetch_users()
    db = connect_to_db()
    db.execute("SELECT * FROM users")
  end

  # Fetch a user
  # @param id [Integer] the id of the user
  # @return [Hash] the user
  def fetch_user(id)
    db = connect_to_db()
    db.execute("SELECT * FROM users WHERE Id = ?", id).first
  end

  # Update a user
  # @param id [Integer] the id of the user
  # @param email [String] the email of the user
  # @param password [String] the password of the user
  # @param username [String] the username of the user
  # @return [nil]
  def update_user(id, email, password, username)
    db = connect_to_db()
    db.execute("UPDATE users SET Email = ?, Pwd = ?, Name = ? WHERE Id = ?", email, BCrypt::Password.create(password),
               username, id)
  end

  # Delete a user
  # @param id [Integer] the id of the user
  # @return [nil]
  def delete_user(id)
    db = connect_to_db()
    db.execute("DELETE FROM users WHERE Id = ?", id)
  end

  # Update a user's roles
  #
  # It will delete all roles of the user and then add the new roles
  # This is to avoid duplicates and to make sure the roles are up to date
  #
  # @param id [Integer] the id of the user
  # @param roles [Array] the roles of the user
  # @return [nil]
  def update_users_roles(id, roles)
    db = connect_to_db()
    db.execute("DELETE FROM role_users WHERE user_id = ?", id)
    roles.each do |role|
      db.execute("INSERT INTO role_users (user_id, role_id) VALUES (?, ?)", id, role)
    end
  end

  # Fetch a user's roles
  #
  # @param id [Integer] the id of the user
  #
  # @return [Array<Hash>] the roles of the user
  def fetch_user_roles(id)
    db = connect_to_db()
    db.execute("SELECT * FROM roles INNER JOIN role_users on role_users.role_id = roles.id WHERE user_id = ?", id)
  end

  # Get the user from the database
  #
  # @param email [String] the email of the user
  #
  # @return [Hash] the user
  def fetch_user(email)
    db = connect_to_db()
    user = db.execute("SELECT * FROM users WHERE Email = ?", email).first
  end

  # Create a new exercise in the database
  #
  # @param name [String] the name of the exercise
  # @param instructions [String] the instructions of the exercise
  # @param difficulty [String] the difficulty of the exercise
  # @param test_file [String] the test file of the exercise
  # @param icon [String] the icon of the exercise
  # @param blurb [String] the blurb of the exercise
  #
  # @return [nil]
  def new_exercise(name, instructions, difficulty, test_file, icon, blurb)
    db = connect_to_db()
    db.execute(
      "INSERT INTO exercises (Name, Instructions, Difficulty, Test_File, Icon, blurb) VALUES (?, ?, ?, ?, ?, ?)", name, instructions, difficulty, test_file, icon, blurb
    )
  end

  # Fetch all exercises
  #
  # @param n [Integer] the number of exercises to fetch
  #
  # @return [Array<Hash>] the exercises
  def fetch_exercises(n)
    db = connect_to_db()
    db.execute("SELECT * FROM exercises LIMIT ?", n)
  end

  # Fetch an exercise
  #
  # @param id [Integer] the id of the exercise
  #
  # @return [Hash] the exercise
  def fetch_exercise(id)
    db = connect_to_db()
    db.execute("SELECT * FROM exercises  WHERE Id = ?", id).first
  end

  # Update an exercise
  # @param id [Integer] the id of the exercise
  # @param name [String] the name of the exercise
  # @param instructions [String] the path to instructions of the exercise
  # @param difficulty [String] the difficulty of the exercise
  # @param test_file [String] the path to test file of the exercise
  # @param icon [String] the path to icon of the exercise
  # @param blurb [String] the blurb of the exercise
  def update_exercise(id, name, instructions, difficulty, test_file, icon, blurb)
    db = connect_to_db()
    db.execute(
      "UPDATE exercises SET Name = ?, Instructions = ?, Difficulty = ?, Test_File = ?, Icon = ?, blurb = ? WHERE Id = ?", name, instructions, difficulty, test_file, icon, blurb, id
    )
  end

  # Delete an exercise
  #
  # @param id [Integer] the id of the exercise
  def delete_exercise(id)
    db = connect_to_db()
    db.execute("DELETE FROM exercises WHERE Id = ?", id)
  end

  def fetch_roles()
    db = connect_to_db()
    db.execute("SELECT * FROM roles")
  end

  def fetch_role_count(id)
    db = connect_to_db()
    db.execute("SELECT * FROM role_users WHERE role_id = ?", id).length
  end

  def fetch_role_and_users(id)
    db = connect_to_db()
    db.execute(
      "SELECT * FROM roles INNER JOIN role_users on role_users.role_id = roles.id INNER JOIN users on role_users.user_id = users.id WHERE role_id = ?", id
    )
  end

  def fetch_role(id)
    db = connect_to_db()
    db.execute("SELECT * FROM roles WHERE Id = ?", id).first
  end

  def new_role(name, level)
    db = connect_to_db()
    db.execute("INSERT INTO roles (Name, Level) VALUES (?, ?)", name, level)
  end

  def update_role(id, name, level)
    db = connect_to_db()
    db.execute("UPDATE roles SET Name = ?, Level = ? WHERE Id = ?", name, level, id)
  end

  def delete_role(id)
    db = connect_to_db()
    db.execute("DELETE FROM roles WHERE Id = ?", id)
  end

  def fetch_solutions(id)
    db = connect_to_db()
    db.execute(
      "SELECT name, solution, solution_id FROM solutions INNER JOIN users on solutions.user_id = id  WHERE exercise_id = ? ", id
    )
  end

  def create_solution(user_id, exercise_id, solution)
    db = connect_to_db()
    db.execute("INSERT INTO solutions (exercise_id, Solution, user_id) VALUES (?, ?, ?)", exercise_id, solution,
               user_id)
  end

  def fetch_solution(id)
    db = connect_to_db()
    db.execute("SELECT * FROM solutions WHERE solution_id = ?", id).first
  end

  def fetch_solution_and_users(id)
    db = connect_to_db()
    db.execute("SELECT * FROM solutions INNER JOIN users on solutions.user_id = id WHERE solution_id = ?", id).first
  end

  def delete_solution(id)
    db = connect_to_db()
    db.execute("DELETE FROM solutions WHERE solution_id = ?", id)
  end

  def update_solution(id, solution)
    db = connect_to_db()
    db.execute("UPDATE solutions SET Solution = ? WHERE solution_id = ?", solution, id)
  end
end
