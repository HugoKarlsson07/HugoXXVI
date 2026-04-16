module Model
  # Returns the database connection.
  # Ensures a single instance of the SQLite3 database with results_as_hash enabled.
  # @return [SQLite3::Database] The database instance.
  def db()
    @db ||= begin
      d = SQLite3::Database.new('db/databas.db')
      d.results_as_hash = true
      d
    end
  end

  # Checks if a user has liked a specific ad.
  # @param ad_id [Integer] The ID of the ad.
  # @param user_id [Integer, nil] The ID of the user, or nil if not logged in.
  # @return [Boolean] True if the user has liked the ad, false otherwise.
  def liked_by_user?(ad_id, user_id)
    return false if user_id.nil?
    rows = db.execute("SELECT 1 FROM likes WHERE ad_id = ? AND user_id = ?", [ad_id, user_id])
    !rows.empty?
  end

  # Returns the number of likes for a specific ad.
  # @param ad_id [Integer] The ID of the ad.
  # @return [Integer] The count of likes.
  def like_count(ad_id)
    db.execute("SELECT COUNT(*) AS count FROM likes WHERE ad_id = ?", [ad_id]).first["count"]
  end

  # Toggles like for an ad by a user.
  # If liked, removes the like; if not, adds it.
  # @param ad_id [Integer] The ID of the ad.
  # @param user_id [Integer] The ID of the user.
  # @return [void]
  def update_database_likes(ad_id, user_id)
    if liked_by_user?(ad_id, user_id)
      db.execute("DELETE FROM likes WHERE ad_id = ? AND user_id = ?", [ad_id, user_id])
    else
      db.execute("INSERT OR IGNORE INTO likes (user_id, ad_id) VALUES (?, ?)", [user_id, ad_id])
    end
  end

  # Creates a new user in the database.
  # @param name [String] The user's name.
  # @param email [String] The user's email.
  # @param telephone [String] The user's telephone.
  # @param pwd_digest [String] The hashed password.
  # @return [void]
  def create_user(name, email, telephone, pwd_digest)
    db.execute(
    "INSERT INTO users (name, email, telephone, password_digest) VALUES (?, ?, ?, ?)",
    [name, email, telephone, pwd_digest])
  end

  # Retrieves a user by email.
  # @param email [String] The user's email.
  # @return [Hash, nil] The user data or nil if not found.
  def get_user(email)
    db.execute(
      "SELECT user_id, user_tag_id, password_digest FROM users WHERE email = ?",
      [email]
    ).first
  end
  
  # Loads categories and locations into instance variables.
  # @return [void]
  def load_select_data
    @categories = db.execute("SELECT * FROM categories")
    @locations  = db.execute("SELECT * FROM locations")
  end

  # Loads all ads with owner information.
  # @return [void]
  def load_ads_data()
     @ads = db.execute("SELECT ads.*, users.name AS owner_name, users.email AS owner_email, users.telephone AS owner_phone FROM ads LEFT JOIN users ON ads.user_id = users.user_id")
  end

  # Loads a specific ad by ID.
  # @param ad_id [Integer] The ID of the ad.
  # @return [Hash, nil] The ad data or nil if not found.
  def load_ad_id(ad_id)
    db.execute("SELECT * FROM ads WHERE ad_id = ?", [ad_id]).first
  end

  # Loads ads for a specific user.
  # @param user_id [Integer] The ID of the user.
  # @return [void]
  def load_ads_user_data(user_id)
    @my_ads = db.execute("SELECT * FROM ads WHERE user_id = ?", user_id)
  end

  # Creates a new ad.
  # @param title [String] The ad title.
  # @param description [String] The ad description.
  # @param price [Float] The ad price.
  # @param image_path [String, nil] The path to the image.
  # @param user_id [Integer] The ID of the user creating the ad.
  # @param category_id [Integer] The ID of the category.
  # @param location_id [Integer] The ID of the location.
  # @return [void]
  def create_new_ad(title, description, price,image_path, user_id, category_id, location_id)
    db.execute("INSERT INTO ads (title, description, price, status, image_path, user_id, category_id, location_id) 
              VALUES (?, ?, ?, ?, ?, ?, ?, ?)", 
              [title, description, price, "Aktiv", image_path, user_id, category_id, location_id])
  end

  # Deletes an ad by ID.
  # @param ad_id [Integer] The ID of the ad to delete.
  # @return [void]
  def delete_ad(ad_id)
    db.execute("DELETE FROM ads WHERE ad_id = ?", [ad_id])
  end

  def update_ad(title, description, price, category_id, location_id, image_path, ad_id)
    db.execute("UPDATE ads SET title = ?, description = ?, price = ?, category_id = ?, location_id = ?, image_path = ? WHERE ad_id = ?",
             [title, description, price, category_id, location_id, image_path, ad_id])
  end

  # Checks if a user with the given email already exists.
  # @param email [String] The email to check.
  # @return [Boolean] True if the user exists, false otherwise.
  def existing_user(email)
    user = db.execute("SELECT user_id FROM users WHERE email = ?",[email]).first
    !user.nil?
  end
end