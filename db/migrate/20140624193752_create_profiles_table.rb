class CreateProfilesTable < ActiveRecord::Migration
  def change
  	create_table :profiles do |entry|
  		entry.string :username
  		entry.string :password
  		entry.string :hometown
  		entry.datetime :bday
  		entry.integer :user_id		
  	end
  end
end