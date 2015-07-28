require 'sinatra' 
require 'sinatra/activerecord'
require 'bundler/setup'  
require 'rack-flash'
require 'bcrypt'
require 'date'
require 'carrierwave'
require 'carrierwave/orm/activerecord'
require 'fog'
require 'pony'

configure(:production) {CarrierWave.configure do |config|
  config.fog_credentials = {
    :provider               => 'AWS',                        # required
    :aws_access_key_id      => ENV['S3_KEY'],                        # required
    :aws_secret_access_key  => ENV['S3_SECRET_KEY'],                        # required
  }

  config.fog_directory  = "crutespeaks-assets"
  config.fog_public     = true
end}

use Rack::Flash, :sweep => true
set :sessions, true
configure(:development) {set :database, {adapter: "sqlite3", database: "sqlite3:exampledb.sqlite3"}}
configure(:development) {set :session_secret, 'This is a secret key'}
configure(:production) {set :session_secret, ENV['SECRET_SESSION']}
require './models'

set :logging, true


def current_profile   
		if session[:user_id]    
			if Profile.find(session[:user_id]).blank? then redirect "/logout" else @current_profile = Profile.find(session[:user_id]) end
		else
			redirect "/login"
		end
end

def check_date
	time_now = Time.now
	if Event.all.first
		events = Event.all
		events.each do |event|
			if time_now  > (event.date_time + ((60*60)*240))
				if EventAttendee.where(event_id: event.id).first
				   EventAttendee.where(event_id: event.id).destroy_all
				end
				event.destroy
			end
		end
	end
end

def check_event(event)
	time_now = Time.now
	if   ((event+ ((60*60)*12)) > time_now) && (event < ((time_now + ((60*60)*336))))
		return true
	else
		return false
	end
end

def check_bday(bday)
	time_now = Time.now
	time_now_year = time_now.strftime('%Y')
	bday_month = bday.strftime('%b')
	bday_day = bday.strftime('%d')
	bday = Time.parse("#{time_now_year}-#{bday_month}-#{bday_day}")
	if   ((bday + ((60*60)*48)) > time_now) && (bday < (time_now + ((60*60)*672)))
		return true
	else
		return false
	end
end

get '/delete_post' do
	Post.find(params[:pid]).destroy
	Comment.where(post_id: params[:pid]).destroy_all
	redirect "/home"
end

get '/delete_profile_post' do
	Post.find(params[:pid]).destroy
	Comment.where(post_id: params[:pid]).destroy_all
	redirect "/profile?un=#{params[:un]}&ui=#{params[:ui]}"
end

get '/edit_post' do
	@post = Post.find(params[:pid])
	@post.string_data = params[:post]
	@post.save
	redirect "/home"
end

get '/' do
	current_profile
	redirect "/home"
end

get '/home' do
	current_profile
	if !params.blank? then puts "Params are blank?" + params.inspect end
	erb :home
end

get '/profile' do
	current_profile	
	if params.blank? then redirect "/profiles" end
	if @current_profile.username == params[:un] then redirect "/home" end
	@user_profile = Profile.find_by_username_and_user_id params[:un],params[:ui]
	#puts "My current user is " + @current_profile.inspect
	#puts "My profile is " + @user_profile.inspect
	@user = User.find(@user_profile.user_id)
	erb :profile
end

get '/profiles' do
	current_profile	
	erb :profiles
end

get '/login' do
	erb :login, :layout => :layout_login
end

post '/login-process' do
	#puts "my params are" + params.inspect 
	@userin = Profile.find_by_username(params[:username].downcase)
	if @userin && @userin.password == params[:password] && @userin.approved == true
		session[:user_id] = @userin.id
		flash[:notice] = "Welcome back #{@userin.username.capitalize}"
		redirect "/home"   
	else
		flash[:notice] = "Oh no. Something's wrong."
		redirect "/login"   
	end 
end

get '/sign_up' do
	erb :sign_up, :layout => :layout_signup
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
			@date = "#{params[:year]}-#{params[:month]}-#{params[:day]}"
			User.create(email: params[:email].downcase, lname: params[:lname].downcase, fname: params[:fname].downcase)
			@signup = User.find_by_email_and_lname_and_fname(params[:email].downcase, params[:lname].downcase, params[:fname].downcase)
			Profile.create(bday: @date, username: params[:username].downcase, password: params[:password], hometown: params[:hometown].downcase, user_id: @signup.id)
			@signup2 = Profile.find_by_username_and_user_id(params[:username].downcase, @signup.id)
			if params[:file].blank?
				#@signup2.avatar = File.open('public/default_picture/default.jpg')
			else
				@signup2.avatar = params[:file]
				Picture.create(user_id: @signup.id, avatar: params[:file])
			end
			@signup2.save
			#session[:user_id] = @signup2.id  
			Notification.create(notice: "#{@signup.lname.capitalize}, #{@signup.fname.capitalize} is waiting to be approved.", user_id: @signup.id) 
		    options = {
  				:to => @signup.email,
  				:from => "dcrute25@hotmail.com",
  				:subject => "Welcome #{@signup2.username.capitalize} to FamilyTies",
  				:headers => { 'Content-Type' => 'text/html' },
  				:body => erb(:welcome_email, :layout => :layout_email),
 				:via => :smtp,
  				:via_options => {
   					:address => 'smtp.sendgrid.net',
    				:port => '587',
    				:domain => 'heroku.com',
    				:user_name => ENV['SENDGRID_USERNAME'],
    				:password => ENV['SENDGRID_PASSWORD'],
    				:authentication => :plain,
    				:enable_starttls_auto => true
    			}
  			}
		    Pony.mail(options)
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
	current_profile
	erb :edit_account
end

post '/edit-account-process' do
	current_profile
	# puts "\n\nmy paramaters are: #{params.inspect}\]\n\n"
	@user = Profile.find(@current_profile.id).user
	@user.email = params[:email].downcase unless params[:email].blank?
	@user.lname = params[:lname].downcase unless params[:lname].blank?
	@user.fname = params[:fname].downcase unless params[:fname].blank?
	@user.save
	if params[:file].blank?
		#do nothing
	else
		@current_profile.avatar = params[:file]
		Picture.create(user_id: @user.id, avatar: params[:file])
	end
	@date = "#{params[:year]}-#{params[:month]}-#{params[:day]}" unless params[:year].blank?
	@current_profile.bday = @date unless @date.blank?
	@current_profile.password = params[:password] unless params[:password].blank?
	@current_profile.hometown = params[:hometown].downcase unless params[:hometown].blank?
	@current_profile.save  
	flash[:notice] = "Your Account has been Updated!" 
	redirect "/home"      
end

post '/edit-group-process' do
	current_profile
	# puts "\n\nmy paramaters are: #{params.inspect}\]\n\n"
	@group = Group.find(@current_profile.group_id)
	@group.name = params[:name].downcase unless params[:name].blank?
	@user.save
	if params[:file].blank?
		#do nothing
	else
		@group.avatar = params[:file]
	end
	@group.save  
	flash[:notice] = "Your group has been Updated!" 
	redirect "/admin_screen"      
end

get '/delete_account' do
	current_profile
	flash[:notice] = "Are you sure you want to delete this account" 
	erb :delete_account
end

post '/delete' do
	current_profile
	@user = Profile.find(@current_profile.id).user
	session.clear
	Post.where(:user_id => @current_profile.user_id).destroy_all unless Post.where(:user_id => @current_profile.user_id).blank?
	UserFollow.where(:user_id => @current_profile.user_id).destroy_all unless UserFollow.where(:user_id => @current_profile.user_id).blank?
	Event.where(:user_id => @current_profile.user_id).destroy_all unless Event.where(:user_id => @current_profile.user_id).blank?
	EventAttendee.where(:user_id => @current_profile.user_id).destroy_all unless EventAttendee.where(:user_id => @current_profile.user_id).blank?
	@current_profile.destroy
	@user.destroy
	flash[:notice] = "Your account was deleted succesffuly!" 
	redirect "/home"      
end

get '/follow' do
	current_profile
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
	current_profile
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
		@date = "#{params[:year]}-#{params[:month]}-#{params[:day]}"
		bday = DateTime.parse(@date)
		@profile = Profile.find_by_username_and_hometown_and_bday params[:username].downcase, params[:hometown].downcase, bday
		@user = User.find_by_email(params[:email].downcase)
		@profile_check = Profile.find_by_user_id(@user.id)
		puts "\n\n"
		puts @user.inspect
		puts @profile.inspect
		puts @profile_check.inspect
		if @profile.approved == true
			if @profile.username == @profile_check.username && @profile.hometown == @profile_check.hometown && @profile.bday == @profile_check.bday
				#random_password = Array.new(10).map { (65 + rand(58)).chr }.join
				#@profile_check.password = random_password
				#@profile_check.save!
				session[:user_id] = @profile_check.id
				flash[:notice] = "Take this time to update your password!"
				redirect "/edit_account"
			else
				flash[:notice] = "That information is incorrect. Please try again"
				redirect "/home"
			end
		else
			flash[:notice] = "Your account has not be approved yet. Please try again later"
			redirect "/home"
		end
	end
end


get '/forgot_password' do
  erb :forgot_password, :layout => :layout_forgot
end

get '/post' do
	current_profile
	Post.create(string_data: params[:post], user_id: @current_profile.user_id, user_wall_id: @current_profile.user_id) unless params[:post].blank?
	redirect "/home"      
end

get '/admin' do
	current_profile
	if @current_profile.admin == true
		erb :admin_screen
	else
		redirect '/home'
	end   
end

get '/approve_user' do
	current_profile
	if @current_profile.admin == true
		@profilein = Profile.find_by_user_id(params[:ui])
		note = Notification.find_by_user_id @profilein.user_id
		puts "user in is #{@profilein.inspect}"
		if !@profilein.blank?
			@profilein.approved = true
			@profilein.admin = false
			@profilein.save
			note.destroy unless note.blank?
		end
			@user = User.find(@profilein.user_id)
			options = {
  				:to => @user.email,
  				:from => "dcrute25@hotmail.com",
  				:subject => "#{@profilein.username.capitalize} is Approved for FamilyTies",
  				:headers => { 'Content-Type' => 'text/html' },
  				:body => erb(:approved_email, :layout => :layout_email),
 				:via => :smtp,
  				:via_options => {
   					:address => 'smtp.sendgrid.net',
    				:port => '587',
    				:domain => 'heroku.com',
    				:user_name => ENV['SENDGRID_USERNAME'],
    				:password => ENV['SENDGRID_PASSWORD'],
    				:authentication => :plain,
    				:enable_starttls_auto => true
    			}
  			}
		    Pony.mail(options)
		redirect '/admin'
	else
		redirect '/home'
	end   
end

get '/reject_user' do
	current_profile
	if @current_profile.admin == true
		Profile.find_by_user_id(params[:ui]).destroy unless params[:ui].blank?
		User.find(params[:ui]).destroy unless params[:ui].blank?
		Notification.find_by_user_id(params[:ui]).destroy unless params[:ui].blank?
		redirect '/admin'
	else
		redirect '/home'
	end   
end

get '/post_profile' do
	current_profile
	Post.create(string_data: params[:post], user_id: @current_profile.user_id, user_wall_id: params[:ui]) unless params[:post].blank?
	redirect "/profile?un=#{params[:un]}&ui=#{params[:ui]}"      
end

# get '/post_profiles' do
# 	current_profile
# 	create_post unless params[:post].blank?
# 	redirect "/profiles"      
# end

get '/gallery' do
	current_profile
	erb :home_gallery
end

get '/profile-gallery' do
	current_profile
	@user_profile = Profile.find_by_username_and_user_id params[:un],params[:ui]
	erb :profile_gallery
end

post '/add-to-gallery' do
	current_profile
	Picture.create() unless params[:file].blank?
	@picture = Picture.last
	@picture.avatar = params[:file]
	@picture.user_id = @current_profile.user_id
	@picture.save
	redirect "/gallery"      
end

get '/delete-photo' do
	@current_profile = current_profile
	picture = Picture.find(params[:id])
	if @current_profile.avatar.url == picture.avatar.url
		flash[:notice] = "You can delete a photo that is currently your profile pic!"
	else
		picture.destroy
	end		
	redirect '/gallery'
end

get '/events' do
	current_profile
	check_date
	erb :events	
end

post '/event-process' do
	current_profile
	date = "#{params[:year]}-#{params[:month]}-#{params[:day]} #{params[:hour]}:#{params[:minute]}:00"
	if Event.find_by_title_and_date_time params[:title].downcase, date
		flash[:notice] = "Sorry there is already an event on that date with that title." 
	else
		@event = Event.create(title: params[:title].downcase, location: params[:location], description: params[:description], user_id: @current_profile.user_id, date_time: date)
		EventAttendee.create(user_id: @current_profile.user_id, event_id: @event.id)
		flash[:notice] = "Your event was created. Hope to see you soon!" 
	end
	redirect "/events" 
end

get '/event' do
	current_profile	
	if params.blank? then redirect "/events" end
	@event = Event.find(params[:ei])
	@user = User.find(@event.user_id)
	erb :event
end

get '/attend' do
	current_profile
	EventAttendee.create(user_id: @current_profile.user_id, event_id: params[:ei])
	@event = Event.find(params[:ei])
	flash[:notice] = "You are no longer attending #{@event.title} on #{@event.date_time.strftime('%b %d, %Y')}#{@event.date_time.strftime('at %I:%M %p')}" 
	redirect "/event?ei=#{params[:ei]}"      
end

get '/unattend' do
	current_profile
	@event_attending= Event.find(params[:ei])
	flash[:notice] = "You are no longer attending #{@event_attending.title} on #{@event_attending.date_time.strftime('%b %d, %Y')}#{@event_attending.date_time.strftime('at %I:%M %p')}" 
	@attending = EventAttendee.find_by_user_id_and_event_id @current_profile.user_id, params[:ei]
	@attending.destroy
	redirect "/event?ei=#{params[:ei]}"      
end

get '/delete_event' do
	Event.find(params[:ei]).destroy
	redirect "/events"
end

get '/leave_comment' do
	current_profile
	Comment.create(data: params[:comment], user_id: @current_profile.user_id, post_id: params[:pid])
	redirect "/home"
end

get '/leave_comment_profile' do
	current_profile
	Comment.create(data: params[:comment], user_id: @current_profile.user_id, post_id: params[:pid])
	redirect "/profile?un=#{params[:un]}&ui=#{params[:ui]}"
end

