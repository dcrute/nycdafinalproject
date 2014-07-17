class CreateNotificationsTable < ActiveRecord::Migration
  	def change
  		create_table :notifications do |entry|
  			entry.string :notice
			entry.integer :user_id
  		end
  	end
end