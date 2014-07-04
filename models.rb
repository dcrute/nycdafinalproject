class AvatarUploader < CarrierWave::Uploader::Base
  storage :file
  
  def extension_white_list
    %w(jpg jpeg gif png)
  end
  
  def store_dir
    'profile_pictures'
  end
  
end

class User < ActiveRecord::Base
	has_one :profile
	has_many :posts
	has_many :user_follows
	has_many :users, through: :user_follows
end

class Profile < ActiveRecord::Base
	belongs_to :user
	mount_uploader :avatar, AvatarUploader
	include BCrypt

  def password
    @password ||= Password.new(password_hash)
  end

  def password=(new_password)
    @password = Password.create(new_password)
    self.password_hash = @password
  end
end

class Post < ActiveRecord::Base
	belongs_to :user
end

class UserFollow <ActiveRecord::Base
	belongs_to :user
end