require 'sinatra' 
require 'sinatra/activerecord'
require 'bundler/setup'  
require 'rack-flash' 
enable :sessions 
use Rack::Flash, :sweep => true

configure(:development) {set :database, "sqlite3:exampledb.sqlite3"}

require './models'


set :sessions, true
def current_user   
		if session[:user_id]     
			@current_user = Profile.find(session[:user_id])  
		else
			redirect "/login"
		end
end

def create_post
	Post.create()
	@post = Post.last
	@post.string_data = params[:post]
	@post.user_id = @current_user.user_id
	@post.save
end
	
get '/' do
	@current_user = current_user
	redirect "/home"
end

get '/home' do
	@current_user = current_user
	if !params.blank? then puts "Params are blank?" + params.inspect end
	erb :home
end

get '/profile' do
	@current_user = current_user	
	if params.blank? then redirect "/profiles" end
	@user_profile = Profile.find_by_username_and_user_id params[:un],params[:ui]
	#puts "My current user is " + @current_user.inspect
	#puts "My profile is " + @user_profile.inspect
	@user = User.find(@user_profile.user_id)
	erb :profile
end

get '/profiles' do
	@current_user = current_user	
	erb :profiles
end

get '/login' do
	@current_user == nil
	erb :login
end

post '/login-process' do
	#puts "my params are" + params.inspect 
	@userin = Profile.where(username: params[:username]).first
	if @userin && @userin.password == params[:password] 
		session[:user_id] = @userin.id
		flash[:notice] = "You're in!!!"
		redirect "/home"   
	else
		flash[:notice] = "Oh no. Something's wrong."
		redirect "/login"   
	end 
end

get '/sign_up' do
	@current_user
	erb :sign_up
end

post '/sign-up-process' do
	#puts "my params are" + params.inspect
	User.create()
	Profile.create()
	@signup = User.last
	@signup.email = params[:email]
	@signup.lname = params[:lname]
	@signup.fname = params[:fname]
	@signup.save
	@signup2 = Profile.last
	@signup2.bday = params[:bday]
	@signup2.username = params[:username]
	@signup2.password = params[:password]
	@signup2.hometown = params[:hometown]
	@signup2.user_id = @signup.id
	@signup2.save
	session[:user_id] = @signup2.id   
	flash[:notice] = "Welcome to the cool kids club!" 
	redirect "/home"      
end


get '/logout' do
	session.clear
	flash[:notice] = "See you next time."
	redirect "/home"
end

get '/edit_account' do
	@current_user = current_user
	erb :edit_account
end

post '/edit-account-process' do
	#puts "my params are" + params.inspect
	@current_user = current_user
	@user = Profile.find(@current_user.id).user
	@user.email = params[:email] unless params[:email].blank?
	@user.lname = params[:lname] unless params[:lname].blank?
	@user.fname = params[:fname] unless params[:fname].blank?
	@user.save
	@current_user.bday = params[:bday] unless params[:bday].blank?
	@current_user.password = params[:password] unless params[:password].blank?
	@current_user.hometown = params[:hometown] unless params[:hometown].blank?
	@current_user.save  
	flash[:notice] = "Your Account has been Updated!" 
	redirect "/home"      
end

get '/delete_account' do
	@current_user = current_user
	flash[:notice] = "Are you sure you want to delete this account" 
	erb :delete_account
end

post '/delete' do
	@current_user = current_user
	@user = Profile.find(@current_user.id).user
	session.clear
	Post.where(:user_id => @current_user.user_id).destroy unless Post.where(:user_id => @current_user.user_id).blank?
	@current_user.destroy
	@user.destroy
	flash[:notice] = "Your account was deleted succesffuly!" 
	redirect "/home"      
end

get '/follow' do
	@current_user = current_user
	UserFollow.create()
	@user_follows =  UserFollow.last
	#puts @user_follows.user_id = @current_user.user_id
	#puts @user_follows.user_following_id = params[:ui]
	@user_follows.save
	@followed_user = User.find(params[:ui])
	flash[:notice] = "You are now following #{@followed_user.fname} #{@followed_user.lname}" 
	redirect "/profile?un=#{params[:un]}&ui=#{params[:ui]}"      
end

get '/unfollow' do
	@current_user = current_user
	@followed_user = User.find(params[:ui])
	flash[:notice] = "You are no longer following #{@followed_user.fname} #{@followed_user.lname}" 
	@user_follows = UserFollow.find_by_user_id_and_user_following_id @current_user.user_id, params[:ui]
	@user_follows.destroy
	redirect "/profile?un=#{params[:un]}&ui=#{params[:ui]}"      
end

get '/post' do
	@current_user = current_user
	create_post
	redirect "/home"      
end

get '/post_profile' do
	@current_user = current_user
	create_post
	redirect "/profile?un=#{params[:un]}&ui=#{params[:ui]}"      
end

get '/post_profiles' do
	@current_user = current_user
	create_post
	redirect "/profiles"      
end