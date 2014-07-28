configure(:development) { class AvatarUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick
  storage :file
  process :fix_if_rotation
  process :resize_to_fit => [1000, 1000]

  # version :thumb do
  #   process :resize_to_fill => [125,125]
  # end

  def default_url
    "/default_picture/default.jpg"
  end

  def extension_white_list
    %w(jpg jpeg gif png)
  end

    def store_dir
    "profile_pictures/"
  end

  def fix_if_rotation
    manipulate! do |img|
      img.tap(&:auto_orient)
    end
  end

  
end }

  
configure(:production) { class AvatarUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick  

  process :resize_to_fit => [1000, 1000]
  storage :fog
  # version :thumb do
  #   process :resize_to_fill => [125,125]
  # end

  def default_url
    "/default_picture/default.jpg"
  end

  def extension_white_list
    %w(jpg jpeg gif png)
  end

  def store_dir
    "development/uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end 
end }

class User < ActiveRecord::Base
	has_one :profile
	has_many :posts
  has_many :notifications
	has_many :user_follows
	has_many :users, through: :user_follows
  has_many :pictures
  has_many :events
  has_many :event_attendees
  has_many :events, through: :event_attendees
  has_many :comments
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
  has_many :comments
end

class Picture < ActiveRecord::Base
  belongs_to :user
  mount_uploader :avatar, AvatarUploader
end

class Notification < ActiveRecord::Base
  belongs_to :user
end

class UserFollow <ActiveRecord::Base
	belongs_to :user
end

class Event <ActiveRecord::Base
  belongs_to :user
  has_many :event_attendees
  has_many :users, through: :event_attendees
end

class EventAttendee <ActiveRecord::Base
  belongs_to :user
  belongs_to  :event
end

class Comment <ActiveRecord::Base
  belongs_to :user
  belongs_to :post
end

