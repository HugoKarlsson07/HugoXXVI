require 'sinatra'
require 'slim'
require 'sqlite3'
require 'sinatra/reloader'
require 'bcrypt'

enable :sessions


get('/') do

    db = SQLite3::Database.new('db/todos.db')
    db.results_as_hash = true

    user_id = session[:user_id] 

    if user_id.nil?
        # Om ingen är inloggad, skicka dem till login eller visa en publik sida
        redirect(:login)
    end
    
    @user = db.execute("SELECT * FROM users WHERE user_id = ?", [user_id]).first
    @ads = db.execute("SELECT * FROM ads WHERE user_id = ?", [user_id])
    @messages = db.execute("SELECT * FROM messages WHERE receiver_id = ?", [user_id])

    slim(:index)
end

post('/login') do
  email = params["user"]
  pwd  = params["pwd"]

  db = SQLite3::Database.new('db/databas.db')
  db.results_as_hash = true

  result = db.execute(
    "SELECT user_id, password_digest FROM users WHERE email = ?",
    [email]
  ).first

  if result.nil?
    redirect('/error')
  end

  redirect('/error') if result.empty?

  user_id    = result.first["user_id"]
  pwd_digest = result.first["password_digest"]

  if BCrypt::Password.new(password_digest) == pwd
    session[:user_id] = user_id
    redirect('/')
  else
    redirect('/error')
  end
end