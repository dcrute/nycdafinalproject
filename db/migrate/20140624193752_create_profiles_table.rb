class CreateProfilesTable < ActiveRecord::Migration
  def change
  	create_table :profiles do |entry|
  		entry.string :username
  		entry.string :hometown
  		entry.datetime :bday
  		entry.integer :user_id
  		entry.string :password_hash
  		entry.string :avatar
  	end
  end
end