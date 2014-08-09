class AddUserPostsColumn < ActiveRecord::Migration
  def change
  	add_column :posts, :user_wall_id, :integer
  end
end
