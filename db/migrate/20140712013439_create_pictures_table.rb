class CreatePicturesTable < ActiveRecord::Migration
  	def change
  		create_table :pictures do |entry|
			entry.integer :user_id
			entry.string :avatar
  		end
  	end
end
