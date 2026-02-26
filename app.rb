require 'sinatra'
require 'slim'
require 'sqlite3'
require 'sinatra/reloader'
require 'bcrypt'
require_relative 'models.rb'


enable :sessions


get('/ads') do
  user_inloggad() 
  db()
  load_select_data()
  
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

  redirect('/')
end

get('/') do
  db()
  @ads = db.execute("SELECT * FROM ads")
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
  db()

  if existing_user(email)
    redirect('/error')
  end

  # lösenord
  pwd_digest = BCrypt::Password.create(pwd)

  # skapar nu användare
  db.execute(
    "INSERT INTO users (name, email, telephone, password_digest) VALUES (?, ?, ?, ?)",
    [name, email, telephone, pwd_digest]
  )

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
  db()
  user = db.execute("SELECT * FROM users WHERE email = ?", [email]).first

  if user && BCrypt::Password.new(user["password_digest"]) == pwd
    session[:user_id] = user["user_id"]
    redirect('/')
  else
    redirect('/error')
  end
end
get('/my_ads') do
  user_inloggad()
  db()
  
  @my_ads = db.execute("SELECT * FROM ads WHERE user_id = ?", [session[:user_id]])
  
  slim(:"my_ads")
end

get('/update_ad/:id') do
  user_inloggad()
  db()

  ad_id = params[:id].to_i
  @ad = db.execute("SELECT * FROM ads WHERE ad_id = ?", [ad_id]).first

  
  if @ad.nil? || @ad['user_id'] != session[:user_id]
    redirect '/error'
  end


 load_select_data() #ladar in categorier och locations

  slim(:"updatera")
end

#updaterar ads
post('/update_ad/:id') do
  user_inloggad()
  db()

  ad_id = params[:id].to_i
  ad = db.execute("SELECT * FROM ads WHERE ad_id = ?", [ad_id]).first
  if ad.nil? || ad['user_id'] != session[:user_id]
    redirect '/error'
  end

  title = params[:title]
  description = params[:description]
  price = params[:price]
  category_id = params[:category_id]
  location_id = params[:location_id]
  image_path = ad['image_path']

  # sparar sökvägen till en ny bild som laddas upp
  if params[:image] && params[:image][:filename] && params[:image][:tempfile]
    filename = params[:image][:filename]
    unique_filename = "#{Time.now.to_i}_#{filename}"
    file_path = File.join('public', 'img', unique_filename)
    File.open(file_path, 'wb') do |f|
      f.write(params[:image][:tempfile].read)
    end
    image_path = "/img/#{unique_filename}"
  end

  db.execute("UPDATE ads SET title = ?, description = ?, price = ?, category_id = ?, location_id = ?, image_path = ? WHERE ad_id = ?",
             [title, description, price, category_id, location_id, image_path, ad_id])

  redirect('/my_ads')
end

post('/delete_ad/:id') do
  user_inloggad()
  db()

  ad_id = params[:id].to_i
  
  # Kontrollera att användaren äger annonsen
  ad = db.execute("SELECT * FROM ads WHERE ad_id = ?", [ad_id]).first
  
  if ad && ad["user_id"] == session[:user_id]
    db.execute("DELETE FROM ads WHERE ad_id = ?", [ad_id])
  end
  
  redirect('/my_ads')
end