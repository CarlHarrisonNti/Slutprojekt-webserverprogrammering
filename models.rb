require 'sqlite3'

def connect_to_db()
  db = SQLite3::Database.new("db/main.sqlite")
  db.results_as_hash = true
  return db
end

def register_user(email, password, username)
  db = connect_to_db()
  db.execute("INSERT INTO users (Email, Pwd, Name) VALUES (?, ?, ?)", email, BCrypt::Password.create(password), username)
end

def login_user(email, password)
    db = connect_to_db()
    user = db.execute("SELECT * FROM users WHERE Email = ?", email).first
    if BCrypt::Password.new(user["Pwd"]) == password
        return user
    else
        return nil
    end
end

def new_exercise(name, instructions, difficulty, test_file, icon, blurb)
    db = connect_to_db()
    db.execute("INSERT INTO exercises (Name, Instructions, Difficulty, Test_File, Icon, blurb) VALUES (?, ?, ?, ?, ?, ?)", name, instructions, difficulty, test_file, icon, blurb)
end

def fetch_exercises(n)
    db = connect_to_db()
    db.execute("SELECT * FROM exercises LIMIT ?", n)
end

def fetch_exercise(name)
    db = connect_to_db()
    db.execute("SELECT * FROM exercises WHERE Name = ?", name.capitalize).first
end
