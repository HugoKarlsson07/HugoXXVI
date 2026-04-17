

class User < BaseModel
  def self.create(tabel_name, user_data)
    db.execute("INSERT INTO #{tabel_name} (name, email, telephone, password_digest) VALUES (?, ?, ?, ?)",
    [user_data[:name],user_data[:email],user_data[:telephone],user_data[:password_digest]])
  end

  def self.get_user(tabel_name,email) 
    db.execute(
      "SELECT user_id, user_tag_id, password_digest FROM #{tabel_name} WHERE email = ?",
      [email]
    ).first
  end

  def self.update(tabel_name, user_data)
    db.execute("UPDATE #{tabel_name} SET name = ?, email = ?, telephone = ?, password_digest = ?", [user_data[:name],user_data[:email],user_data[:telephone],user_data[:password_digest]])
  end

  def self.delete(tabel_name, user_id)
    db.execute("DELETE FROM #{tabel_name} WHERE user_id = ?", [user_id])
  end

end


class BaseModel
  def initialize
    
  end

  def db()
    db = SQLite3::Database.new('db/databas.db').results_as_hash = true
  end

  def self.delete(tabel_name, id)
    db.execute("DELETE FROM #{tabel_name} WHERE id = ?", [id])
  end


end
