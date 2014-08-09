class AddUserPostsColumn < ActiveRecord::Migration
  def change
  	add_column :posts, :user_wall_id, :string
  end
end
