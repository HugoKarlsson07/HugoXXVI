require 'sinatra'
require 'slim'
require 'sqlite3'
require 'sinatra/reloader'
require 'bcrypt'


enable :sessions


get('/ads') do
  # Kontrollera att användaren är inloggad
  if session[:user_id].nil?
    redirect '/login'
  end

  db = SQLite3::Database.new('db/databas.db')
  db.results_as_hash = true
  @categories = db.execute("SELECT * FROM categories")
  @locations = db.execute("SELECT * FROM locations")
  
  slim(:"ads")
end

post('/ads') do
  # Hämta data från formuläret
  title = params[:title]
  description = params[:description]
  price = params[:price]
  category_id = params[:category_id]
  location_id = params[:location_id]
  user_id = session[:user_id]
  image_path = nil
  
  # Hantera bilduppladdning
  if params[:image] && params[:image][:filename]
    filename = params[:image][:filename]
    # Skapa en unik filnamn för att undvika konflikter
    unique_filename = "#{Time.now.to_i}_#{filename}"
    file_path = File.join('public', 'img', unique_filename)
    
    # Spara bilden
    File.open(file_path, 'wb') do |f|
      f.write(params[:image][:tempfile].read)
    end
    
    image_path = "/img/#{unique_filename}"
  end
  
  db = SQLite3::Database.new('db/databas.db')
  

  db.execute("INSERT INTO ads (title, description, price, status, image_path, user_id, category_id, location_id) 
              VALUES (?, ?, ?, ?, ?, ?, ?, ?)", 
              [title, description, price, "Aktiv", image_path, user_id, category_id, location_id])

  redirect '/' 
end

get('/') do

    db = SQLite3::Database.new('db/todos.db')
    db.results_as_hash = true
    slim(:index)
end

get('/login') do
  slim(:login)
end
get('/register') do
  slim(:register)
end


post('/register') do
  name = params["user"]
  email = params["email"]
  pwd  = params["pwd"]
  telephone = params["telephone"]

  db = SQLite3::Database.new('db/databas.db')
  db.results_as_hash = true

  # Check if user already exists
  existing_user = db.execute(
    "SELECT user_id FROM users WHERE email = ?",
    [email]
  ).first

  if existing_user
    redirect('/error')
  end

  # Hash the password
  pwd_digest = BCrypt::Password.create(pwd)

  # Create new user
  db.execute(
    "INSERT INTO users (name, email, telephone, password_digest) VALUES (?, ?, ?, ?)",
    [name, email, telephone, pwd_digest]
  )

  # Get the newly created user
  user = db.execute(
    "SELECT user_id FROM users WHERE email = ?",
    [email]
  ).first

  session[:user_id] = user["user_id"]
  redirect('/')
end

post('/login') do
  email = params["email"]
  pwd   = params["pwd"]

  db = SQLite3::Database.new('db/databas.db')
  db.results_as_hash = true

  # Hämta användaren (returnerar en hash eftersom vi kör .first)
  user = db.execute("SELECT * FROM users WHERE email = ?", [email]).first

  if user && BCrypt::Password.new(user["password_digest"]) == pwd
    session[:user_id] = user["user_id"]
    redirect('/')
  else
    redirect('/error')
  end
end
