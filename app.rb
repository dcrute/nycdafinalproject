require 'sinatra' 
require 'sinatra/activerecord'
require 'bundler/setup'  
require 'rack-flash'
require 'bcrypt'
require 'date'
require 'carrierwave'
require 'carrierwave/orm/activerecord'

use Rack::Session::Cookie, :key => 'rack.session', :expire_after => 7200, :secret => 'speak_it'
use Rack::Flash, :sweep => true

configure(:development) {set :database, "sqlite3:exampledb.sqlite3"}

require './models'


set :sessions, true
def current_profile   
		if session[:user_id]    
			if Profile.find(session[:user_id]).blank? then redirect "/logout" else @current_profile = Profile.find(session[:user_id]) end 
		else
			redirect "/login"
		end
end

def create_post
	Post.create()
	@post = Post.last
	@post.string_data = params[:post]
	@post.user_id = @current_profile.user_id
	@post.save
end
	
get '/' do
	@current_profile = current_profile
	redirect "/home"
end

get '/home' do
	@current_profile = current_profile
	if !params.blank? then puts "Params are blank?" + params.inspect end
	erb :home
end

get '/profile' do
	@current_profile = current_profile	
	if params.blank? then redirect "/profiles" end
	@user_profile = Profile.find_by_username_and_user_id params[:un],params[:ui]
	#puts "My current user is " + @current_profile.inspect
	#puts "My profile is " + @user_profile.inspect
	@user = User.find(@user_profile.user_id)
	erb :profile
end

get '/profiles' do
	@current_profile = current_profile	
	erb :profiles
end

get '/login' do
	@current_profile == nil
	erb :login
end

post '/login-process' do
	#puts "my params are" + params.inspect 
	@userin = Profile.find_by_username(params[:username].downcase)
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
	@current_profile
	erb :sign_up
end

post '/sign-up-process' do
	#puts "my params are" + params.inspect
	if Profile.find_by_username(params[:username].downcase)
		flash[:notice] = "Sorry that username is already taken, try another one." 
		redirect "/sign_up"
	else
		if User.find_by_email(params[:email].downcase)
			flash[:notice] = "That e-mail address is already in use. </br>Please use a new e-mail address." 
			redirect "/sign_up"
		else
			User.create()
			Profile.create()
			@signup = User.last
			@signup.email = params[:email].downcase
			@signup.lname = params[:lname].downcase
			@signup.fname = params[:fname].downcase
			@signup.save
			@signup2 = Profile.last
			if params[:file].blank?
				@signup2.avatar = File.open('public/default_picture/default.jpg')
			else
				@signup2.avatar = params[:file]
			end
			@signup2.bday = params[:bday]
			@signup2.username = params[:username].downcase
			@signup2.password = params[:password]
			@signup2.hometown = params[:hometown].downcase
			@signup2.user_id = @signup.id
			@signup2.save
			session[:user_id] = @signup2.id   
			flash[:notice] = "Welcome to the cool kids club!" 
			redirect "/home"
		end    
	end  
end


get '/logout' do
	session.clear
	flash[:notice] = "See you next time."
	redirect "/home"
end

get '/edit_account' do
	@current_profile = current_profile
	erb :edit_account
end

post '/edit-account-process' do
	@current_profile = current_profile
	# puts "\n\nmy paramaters are: #{params.inspect}\]\n\n"
	@user = Profile.find(@current_profile.id).user
	@user.email = params[:email].downcase unless params[:email].blank?
	@user.lname = params[:lname].downcase unless params[:lname].blank?
	@user.fname = params[:fname].downcase unless params[:fname].blank?
	@user.save
	@current_profile.avatar = params[:file] #unless params[:file].blank?
	@current_profile.bday = params[:bday] unless params[:bday].blank?
	@current_profile.password = params[:password] unless params[:password].blank?
	@current_profile.hometown = params[:hometown].downcase unless params[:hometown].blank?
	@current_profile.save  
	flash[:notice] = "Your Account has been Updated!" 
	redirect "/home"      
end

get '/delete_account' do
	@current_profile = current_profile
	flash[:notice] = "Are you sure you want to delete this account" 
	erb :delete_account
end

post '/delete' do
	@current_profile = current_profile
	@user = Profile.find(@current_profile.id).user
	session.clear
	Post.where(:user_id => @current_profile.user_id).destroy unless Post.where(:user_id => @current_profile.user_id).blank?
	@current_profile.destroy
	@user.destroy
	flash[:notice] = "Your account was deleted succesffuly!" 
	redirect "/home"      
end

get '/follow' do
	@current_profile = current_profile
	UserFollow.create()
	@user_follows =  UserFollow.last
	@user_follows.user_id = @current_profile.user_id
	@user_follows.user_following_id = params[:ui]
	@user_follows.save
	@followed_user = User.find(params[:ui])
	flash[:notice] = "You are now following #{@followed_user.fname} #{@followed_user.lname}" 
	redirect "/profile?un=#{params[:un]}&ui=#{params[:ui]}"      
end

get '/unfollow' do
	@current_profile = current_profile
	@followed_user = User.find(params[:ui])
	flash[:notice] = "You are no longer following #{@followed_user.fname} #{@followed_user.lname}" 
	@user_follows = UserFollow.find_by_user_id_and_user_following_id @current_profile.user_id, params[:ui]
	@user_follows.destroy
	redirect "/profile?un=#{params[:un]}&ui=#{params[:ui]}"      
end

post '/password_reset' do
	if User.find_by_email(params[:email]).blank?
		flash[:notice] = "There is no record of an account with the e-mail address #{params[:email]}"
		redirect "/login"
	else
		bday = DateTime.parse(params[:bday])
		@profile = Profile.find_by_username_and_hometown_and_bday params[:username].downcase, params[:hometown].downcase, bday
		@user = User.find_by_email(params[:email].downcase)
		@profile_check = Profile.find_by_user_id(@user.id)
		puts "\n\n"
		puts @user.inspect
		puts @profile.inspect
		puts @profile_check.inspect
		if @profile.username == @profile_check.username && @profile.hometown == @profile_check.hometown && @profile.bday == @profile_check.bday
			#random_password = Array.new(10).map { (65 + rand(58)).chr }.join
			#@profile_check.password = random_password
			#@profile_check.save!
			session[:user_id] = @profile_check.id
			flash[:notice] = "Take this time to update your password!"
			redirect "/edit_account"
		else
			flash[:notice] = "That information is incorrect. Please try again"
		end
	end
end

get '/forgot_password' do
  erb :forgot_password
end

get '/post' do
	@current_profile = current_profile
	create_post unless params.[:post].blank?
	redirect "/home"      
end

get '/post_profile' do
	@current_profile = current_profile
	create_post unless params.[:post].blank?
	redirect "/profile?un=#{params[:un]}&ui=#{params[:ui]}"      
end

get '/post_profiles' do
	@current_profile = current_profile
	create_post unless params.[:post].blank?
	redirect "/profiles"      
end