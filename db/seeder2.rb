require 'sqlite3'
require 'bcrypt'

db = SQLite3::Database.new("prog2.db")

def seed!(db)
  puts "Using db file: prog2.db"
  puts "🧹 Dropping old tables..."
  drop_tables(db)
  puts "🧱 Creating tables..."
  create_tables(db)
  puts "🍎 Populating tables..."
  populate_tables(db)
  puts "✅ Done seeding the database!"
end

def drop_tables(db)
  db.execute('DROP TABLE IF EXISTS likes')
  db.execute('DROP TABLE IF EXISTS messages')
  db.execute('DROP TABLE IF EXISTS ads')
  db.execute('DROP TABLE IF EXISTS locations')
  db.execute('DROP TABLE IF EXISTS categories')
  db.execute('DROP TABLE IF EXISTS users')
end

def create_tables(db)
  # Users
  db.execute('CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT, 
    name TEXT NOT NULL, 
    email TEXT UNIQUE NOT NULL, 
    telephone TEXT, 
    password_digest TEXT, 
    user_tag_id INTEGER DEFAULT 1
  )') #user tag är nivå du börjar på 1 och behöver läggas in som 2 för att bli admin.

  # Categories
  db.execute('CREATE TABLE IF NOT EXISTS categories (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL
  )')

  # Locations 
  db.execute('CREATE TABLE IF NOT EXISTS locations (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    city TEXT NOT NULL,
    region TEXT
  )')

  # Ads 
  db.execute('CREATE TABLE IF NOT EXISTS ads (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    description TEXT,
    price REAL,
    date_of_creation DATETIME DEFAULT CURRENT_TIMESTAMP,
    status TEXT,
    image_path TEXT,
    FOREIGN KEY (id) REFERENCES users(id),
    FOREIGN KEY (id) REFERENCES categories(id),
    FOREIGN KEY (id) REFERENCES locations(id)
  )')

  
  # Likes
  db.execute('CREATE TABLE IF NOT EXISTS likes (
    id INTEGER,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (id) REFERENCES ads(id) ON DELETE CASCADE
  )')
end 

def populate_tables(db)
  puts " Creating user: Hugo Karlsson"
  
  # Skapa lösenordshash med BCrypt
  password_digest = BCrypt::Password.create('Leiastar1')
  
  #Skapa användaren
  db.execute('INSERT INTO users (name, email, telephone, password_digest, user_tag_id) VALUES (?, ?, ?, ?,?)', 
             ['Hugo Karlsson', 'hugooscark@gmail.com', '0721888592', password_digest, 2]) #nu kommer denna vara admin
  hugo_id = db.last_insert_row_id

  #Skapa en kategori
  db.execute('INSERT INTO categories (name) VALUES (?)', ['Elektronik'])
  cat_id = db.last_insert_row_id

  # Skapa en plats
  db.execute('INSERT INTO locations (city, region) VALUES (?, ?)', ['Stockholm', 'Stockholms län'])
  loc_id = db.last_insert_row_id

  #Skapa en annons som Hugo äger
  db.execute('INSERT INTO ads (title, description, price, status, user_id, id, id) 
              VALUES (?, ?, ?, ?, ?, ?, ?)', 
             ['MacBook Pro M2', 'Säljer min laptop i nyskick.', 15000.0, 'Aktiv', hugo_id, cat_id, loc_id])
  ad_id = db.last_insert_row_id

 

  #Hugo gillar sin egen annons
  db.execute('INSERT INTO likes (id, id) VALUES (?, ?)', [hugo_id, ad_id])
  
  puts "Test data inserted successfully!"
end

seed!(db)