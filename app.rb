require 'sinatra'
require 'json'
require_relative 'my_user_model.rb'


set :port, 8080
set :bind, '0.0.0.0'
enable :sessions

  get '/' do
    @users = User.all()
    erb :index
  end

  get '/users' do
    content_type:json
    User.all.to_json
  end


  post '/sign_in' do
    verify_user = User.authentification(params[:password], params[:email])
    if !verify_user.empty?
      status 200
      session[:user_id] = verify_user[0]["id"]
      return verify_user[0].to_json # Ajout du 'return' pour renvoyer les données
    else
      status 401
      logger.error("Authentication failed for email: #{params[:email]}") # Ajout de logs pour les échecs d'authentification
    end
  end
  

  post '/users' do
    if params[:firstname] != nil
      create_user = User.create(params)
      new_user = User.find(create_user.id)
      user = {
        firstname: new_user.firstname,
        lastname: new_user.lastname,
        age: new_user.age,
        password: new_user.password,
        email: new_user.email
      }.to_json
    else
      check_user = User.authentification(params[:password], params[:email])
      if !check_user[0].empty?
        status 200
        session[:user_id] = check_user[0]["id"]
      else
        status 401
      end
      check_user[0].to_json
    end
  end

  put '/users' do
    User.update(session[:user_id], 'password', params[:password])
    user = User.find(session[:user_id])
    status 200
    user_info = {
      firstname: user.firstname,
      lastname: user.lastname,
      age: user.age,
      password: user.password,
      email: user.email
    }.to_json
  end

  delete '/sign_out' do
    session[:user_id] = nil if session[:user_id]
    status 204
  end

  delete '/users' do
    user_id = session[:user_id]
    halt 401, json({ message: 'Unauthorized' }) if user_id.nil?
    User.new.destroy(user_id)
    session.clear
    status 204
  end