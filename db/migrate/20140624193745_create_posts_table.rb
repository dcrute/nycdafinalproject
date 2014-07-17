class CreatePostsTable < ActiveRecord::Migration
  	def change
  		create_table :posts do |entry|
  			entry.string :string_data
			entry.integer :user_id
  		end
  	end
end