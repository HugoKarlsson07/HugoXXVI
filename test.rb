post('/ads') do
  # Hämta data från formuläret
  title = params[:title]
  description = params[:description]
  price = params[:price]
  category_id = params[:category_id]
  location_id = params[:location_id]
  user_id = session[:user_id]
  image_path = nil
  

  tempfile = params[:file][:tempfile]
  
  # Kör systemets 'file' kommando för att få den sanna MIME-typen
  true_type = `file --mime-type -b #{tempfile.path}`.strip
  
  if true_type == "image/png"
    # Fortsätt med sparandet
    "Detta är en riktig PNG!"
  else
    halt 400, "Snyggt försök, men det där är ingen PNG."
  end
  # Hantera bilduppladdning
  if params[:image] && params[:image][:filename]
    filename = params[:image][:filename]
    # Skapa en unik filnamn för att undvika konflikter genom att ge den tiden som den laddas upp och sen fil namnet som den hade innan.
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