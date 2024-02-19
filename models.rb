require 'sqlite3'

def connect_to_db()
  db = SQLite3::Database.new("db/main.sqlite")
  db.results_as_hash = true
  db
end

def register_user(email, password, username)
  db = connect_to_db()
  db.execute("INSERT INTO users (Email, Pwd, Name) VALUES (?, ?, ?)", email, BCrypt::Password.create(password), username)
end

def fetch_user(id)
  db = connect_to_db()
  db.execute("SELECT * FROM users WHERE Id = ?", id).first
end

def update_user(id, email, password, username)
  db = connect_to_db()
  db.execute("UPDATE users SET Email = ?, Pwd = ?, Name = ? WHERE Id = ?", email, BCrypt::Password.create(password), username, id)
end

def delete_user(id)
  db = connect_to_db()
  db.execute("DELETE FROM users WHERE Id = ?", id)
end

def fetch_users()
  db = connect_to_db()
  db.execute("SELECT * FROM users")
end

def update_users_roles(id, roles)
    db = connect_to_db()
    db.execute("DELETE FROM role_users WHERE user_id = ?", id)
    roles.each do |role|
        db.execute("INSERT INTO role_users (user_id, role_id) VALUES (?, ?)", id, role)
    end
end

def fetch_user_roles(id)
    db = connect_to_db()
    db.execute("SELECT * FROM roles INNER JOIN role_users on role_users.role_id = roles.id WHERE user_id = ?", id)
end

def login_user(email, password)
    db = connect_to_db()
    user = db.execute("SELECT * FROM users WHERE Email = ?", email).first
    if BCrypt::Password.new(user["Pwd"]) == password
        user
    else
        nil
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

def fetch_exercise(id)
    db = connect_to_db()
    db.execute("SELECT * FROM exercises WHERE Id = ?", id).first
end

def update_exercise(id, name, instructions, difficulty, test_file, icon, blurb)
    db = connect_to_db()
    db.execute("UPDATE exercises SET Name = ?, Instructions = ?, Difficulty = ?, Test_File = ?, Icon = ?, blurb = ? WHERE Id = ?", name, instructions, difficulty, test_file, icon, blurb, id)
end

def delete_exercise(id)
    db = connect_to_db()
    db.execute("DELETE FROM exercises WHERE Id = ?", id)
end

def fetch_roles()
    db = connect_to_db()
    db.execute("SELECT * FROM roles")
end

def fetch_role_and_users(id)
    db = connect_to_db()
    db.execute("SELECT * FROM roles INNER JOIN role_users on role_users.role_id = roles.id INNER JOIN users on role_users.user_id = users.id WHERE role_id = ?", id)
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
