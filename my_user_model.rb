require 'sqlite3'

class User
  attr_accessor :id, :firstname, :lastname, :age, :password, :email

  def initialize(id:, firstname:, lastname:, age:, password:, email:)
    @id = id
    @firstname = firstname
    @lastname = lastname
    @age = age
    @password = password
    @email = email
  end

  def self.create(user_info)
    user_info[:id] ||= nil
        user = new(**user_info)
    db = SQLite3::Database.new'db.sql'
    db.execute <<~SQL
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY,
        firstname TEXT,
        lastname TEXT,
        age INTEGER,
        password TEXT,
        email TEXT
       );
     SQL

    db.execute"INSERT INTO users (firstname, lastname, age, password, email) VALUES (?, ?, ?, ?, ?)",
                 [user.firstname, user.lastname, user.age, user.password, user.email]   

    user_id = db.last_insert_row_id
    user
  end

  def self.find(user_id)
    db = SQLite3::Database.new'db.sql'
    db.execute "INSERT INTO users(firstname, lastname, age, email, password) VALUES (?, ?, ?, ?, ?)", user_id[:firstname], user_id[:lastname], user_id[:age], user_id[:email], user_id[:password]
    user = User.new(user_id[:firstname], user_id[:lastname], user_id[:age], user_id[:email],  )
    user.id = db.last_insert_row_id
    db.close
    return user
  end
  

  def self.all
    db = SQLite3::Database.new'db.sql'
    users = {}
    db.execute("SELECT * FROM users").each do |user|
      users[user[0]] = {
        firstname: user[1],
        lastname: user[2],
        age: user[3],
        password: user[4],
        email: user[5]
      }
    end
    users
  end

  def self.update(user_id, attribute, value)
    db = SQLite3::Database.new'db.sql'
    db.execute"UPDATE users SET #{attribute} = ? WHERE id = ?", value, user_id
    User.find(user_id)
  end

  def self.destroy(user_id)
    db = SQLite3::Database.new'db.sql'
    user_delete = db.execute"DELETE FROM users WHERE id = ?", user_id
    user_delete
  end


  private

  def set_attributes(user)
    @firstname = user[1]
    @lastname = user[2]
    @age = user[3]
    @password = user[4]
    @email = user[5]
  end
end



