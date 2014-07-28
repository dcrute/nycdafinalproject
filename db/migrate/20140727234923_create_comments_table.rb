class CreateCommentsTable < ActiveRecord::Migration
  def change
  	create_table :comments do |entry|
  		entry.string :data
  		entry.integer :user_id
  		entry.integer :post_id
  	end
  end
end
