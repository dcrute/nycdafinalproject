class CreateUserFollowsTable < ActiveRecord::Migration
  	def change
  		create_table :user_follows do |entry|
			entry.integer :user_id
			entry.integer :user_following_id		
  		end
  	end
end