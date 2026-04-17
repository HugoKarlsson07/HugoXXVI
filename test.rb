require 'sinatra'          # Web framework
require 'slim'             # Template engine
require 'sqlite3'          # Database library
require 'sinatra/reloader' # Auto-reload for development
require 'bcrypt'           # Password hashing

require_relative './prog2/user.rb'

enable :sessions




get('/register') do 
  slim(:register)
end

post('/users') do
  pwd_digest = BCrypt::Password.create(params["pwd"])

  user_data = {
    name: params["user"],
    email: params["email"],
    telephone: params["telephone"],
    password_digest: pwd_digest
  }
  User.create("users", user_data)
  redirect('/register')
end
