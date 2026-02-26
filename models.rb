def db()
    @db ||= begin
      d = SQLite3::Database.new('db/databas.db')
      d.results_as_hash = true
      d
    end
  end

# Kontrollera att användaren är inloggad
def user_inloggad()
  if session[:user_id].nil?
    redirect '/login'
  end
end

#laddar in categorier som instans variabler
def load_select_data
  @categories = db.execute("SELECT * FROM categories")
  @locations  = db.execute("SELECT * FROM locations")
end

#validerar och kontrollerar om email adress redan finns
def existing_user(email)
  user = db.execute("SELECT user_id FROM users WHERE email = ?",[email]).first
  !user.nil?
end
