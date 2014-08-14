class CreateAlertsTable < ActiveRecord::Migration
  	def change
  		create_table :alerts do |entry|
  			entry.string :alert
			entry.integer :user_id
			entry.integer :post_id
  		end
  	end
end