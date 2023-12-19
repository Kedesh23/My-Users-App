require 'sinatra'
require 'json'
require './my_user_model'

set :bind, '0.0.0.0'
set :port, 8080
enable :sessions
set :views, './views'

# Assume User class methods like create, find, update, destroy are implemented

before do
  content_type 'application/json'
end

get '/' do
    erb :index
  end

# Get all users (without passwords)
get '/users' do
  content_type:json
  User.all.to_json
end

# Create a new user and return user details (without password)
post '/users' do
    if params[:firstname]
      created_user = User.create(params)
      if created_user
        found_user = User.find(created_user.id)
        user_data = {
          firstname: found_user.firstname,
          lastname: found_user.lastname,
          age: found_user.age,
          password: found_user.password,
          email: found_user.email
        }.to_json
        status 200 # Gardé le statut 200 pour la création d'utilisateur réussie
        body user_data
      else
        status 401 # Gardé le même statut pour une erreur de création d'utilisateur
      end
    else
      checked_user = User.authenticate(params[:password], params[:email])
      if !checked_user.empty? && !checked_user[0].empty?
        status 200
        session[:user_id] = checked_user[0]["id"]
      else
        status 401
      end
      body checked_user[0].to_json
    end
end

  

# Sign in a user (create session with user_id) and return user details (without password)
post '/sign_in' do
  # Authenticate user with email and password (not implemented here)
  # Assuming authentication succeeds and returns user_id
  user_id = authenticate_user(params[:email], params[:password]) # Authenticate user method
  if user_id
    session[:user_id] = user_id # Set session for logged-in user
    user = User.find('db.sql', user_id)
    user.delete(:password) if user
    user.to_json
  else
    status 401 # Unauthorized status if authentication fails
  end
end

# Update user's password (requires user to be logged in)
put '/users' do
  user_id = session[:user_id]
  if user_id
    User.update('db.sql', user_id, 'password', params[:password])
    user = User.find('db.sql', user_id)
    user.delete(:password) if user
    user.to_json
  else
    status 401 # Unauthorized status if user is not logged in
  end
end

# Sign out (remove session for the current user)
delete '/sign_out' do
  session[:user_id] = nil # Remove session for logged-in user
  status 204 # No content response
end

# Delete the current user (requires user to be logged in)
delete '/users' do
  user_id = session[:user_id]
  if user_id
    User.destroy('db.sql', user_id)
    session[:user_id] = nil # Remove session for logged-in user after deletion
    status 204 # No content response
  else
    status 401 # Unauthorized status if user is not logged in
  end
end
