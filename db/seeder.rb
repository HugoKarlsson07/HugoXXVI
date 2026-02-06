require 'sqlite3'
require 'bcrypt'

db = SQLite3::Database.new("databas.db")

def seed!(db)
  puts "Using db file: databas.db"
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
    user_id INTEGER PRIMARY KEY AUTOINCREMENT, 
    name TEXT NOT NULL, 
    email TEXT UNIQUE NOT NULL, 
    telephone TEXT, 
    password_digest TEXT
  )')

  # Categories
  db.execute('CREATE TABLE IF NOT EXISTS categories (
    category_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL
  )')

  # Locations 
  db.execute('CREATE TABLE IF NOT EXISTS locations (
    location_id INTEGER PRIMARY KEY AUTOINCREMENT,
    city TEXT NOT NULL,
    region TEXT
  )')

  # Ads 
  db.execute('CREATE TABLE IF NOT EXISTS ads (
    ad_id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    description TEXT,
    price REAL,
    date_of_creation DATETIME DEFAULT CURRENT_TIMESTAMP,
    status TEXT,
    user_id INTEGER,
    category_id INTEGER,
    location_id INTEGER,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (category_id) REFERENCES categories(category_id),
    FOREIGN KEY (location_id) REFERENCES locations(location_id)
  )')

  # Messages 
  db.execute('CREATE TABLE IF NOT EXISTS messages (
    message_id INTEGER PRIMARY KEY AUTOINCREMENT,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    content TEXT,
    sender_id INTEGER,
    receiver_id INTEGER,
    ad_id INTEGER,
    FOREIGN KEY (sender_id) REFERENCES users(user_id),
    FOREIGN KEY (receiver_id) REFERENCES users(user_id),
    FOREIGN KEY (ad_id) REFERENCES ads(ad_id)
  )')

  # Likes
  db.execute('CREATE TABLE IF NOT EXISTS likes (
    user_id INTEGER,
    ad_id INTEGER,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, ad_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (ad_id) REFERENCES ads(ad_id) ON DELETE CASCADE
  )')
end 

def populate_tables(db)
  puts " Creating user: Hugo Karlsson"
  
  # Skapa lösenordshash med BCrypt
  password_digest = BCrypt::Password.create('Leiastar1')
  
  #Skapa användaren
  db.execute('INSERT INTO users (name, email, telephone, password_digest) VALUES (?, ?, ?, ?)', 
             ['Hugo Karlsson', 'hugooscark@gmail.com', '0721888592', password_digest])
  hugo_id = db.last_insert_row_id

  #Skapa en kategori
  db.execute('INSERT INTO categories (name) VALUES (?)', ['Elektronik'])
  cat_id = db.last_insert_row_id

  # Skapa en plats
  db.execute('INSERT INTO locations (city, region) VALUES (?, ?)', ['Stockholm', 'Stockholms län'])
  loc_id = db.last_insert_row_id

  #Skapa en annons som Hugo äger
  db.execute('INSERT INTO ads (title, description, price, status, user_id, category_id, location_id) 
              VALUES (?, ?, ?, ?, ?, ?, ?)', 
             ['MacBook Pro M2', 'Säljer min laptop i nyskick.', 15000.0, 'Aktiv', hugo_id, cat_id, loc_id])
  ad_id = db.last_insert_row_id

  #Skapa ett meddelande
  db.execute('INSERT INTO messages (content, sender_id, receiver_id, ad_id) VALUES (?, ?, ?, ?)', 
             ['Hej! Är priset prutbart?', hugo_id, hugo_id, ad_id])

  #Hugo gillar sin egen annons
  db.execute('INSERT INTO likes (user_id, ad_id) VALUES (?, ?)', [hugo_id, ad_id])
  
  puts "Test data inserted successfully!"
end

seed!(db)