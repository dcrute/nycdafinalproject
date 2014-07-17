class CreateUsersTable < ActiveRecord::Migration
  def change
  		create_table :users do |entry|
  			entry.string :fname
  			entry.string :lname
  			entry.string :email
			entry.datetime :created_at
			entry.datetime :updated_at  		
  		end
  	end
end