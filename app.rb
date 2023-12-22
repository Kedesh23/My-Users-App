require 'sinatra'
require 'json'
require_relative 'my_user_model.rb'

set :port, 8080
set :bind, '0.0.0.0'
enable :sessions

get '/' do
    user = User.new()
    @users = user.all()
    erb :index
end

get '/users' do
 content_type:json
 User.all.to_json
end

post '/sign_in' do
    request.body.rewind
    body = request.body.read

    if body.empty?
        halt 400, { error: "request body is empty" }.to_json
    end

    begin
        data = JSON.parse(body)
    rescue JSON::ParserError
        halt 401, { error: "request body isn't valid JSON" }.to_json
    end

    user = User.find_by(email: data['email'])

    if user && user.authentification(data['password'])
        session[:user_id] = user.id
        {
            id: user.id,
            firstname: user.firstname,
            lastname: user.lastname,
            age: user.age,
            email: user.email
        }.to_json
    else
        halt 401, { error: "Invalid credentials" }.to_json
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
    user = User.find_by(id: session[:user_id])
  
    if user.nil?
      status 404
      return { error: "Utilisateur non trouvé" }.to_json
    end
  
    if params[:password].nil? || params[:password].empty?
      status 404
      return { error: "Le champ 'password' est vide" }.to_json
    end
  
    begin
      user.update!(password: params[:password])
  
      # Si la mise à jour réussit, renvoyer les informations de l'utilisateur mis à jour
      status 200
      user_info = {
        firstname: user.firstname,
        lastname: user.lastname,
        age: user.age,
        email: user.email
      }
      return user_info.to_json
    rescue ActiveRecord::RecordInvalid => e
      # Si la mise à jour échoue à cause de la validation du modèle
      status 422
      return { error: e.message }.to_json
    rescue => e
      # Si une autre erreur non prévue se produit
      status 500
      logger.error("Erreur lors de la mise à jour du mot de passe : #{e.message}")
      return { error: "Une erreur est survenue lors de la mise à jour du mot de passe" }.to_json
    end
  end
  
  

  delete '/users' do
    user = User.new()
    id = session[:user_id]
    if id
        user.destroy(id)
        session.delete('user_id')
        "User successfully deleted"
    else
        "Not authorized"
    end
end

delete '/users' do
 user_id = session[:user_id]
 halt 401, json({ message: 'Unauthorized' }) if user_id.nil?
 User.new.destroy(user_id)
 session.clear
 status 204
end