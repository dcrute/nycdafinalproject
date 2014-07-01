class User < ActiveRecord::Base
	has_one :profile
	has_many :posts
	has_many :user_follows
	has_many :users, through: :user_follows
end

class Profile < ActiveRecord::Base
	belongs_to :user
end

class Post < ActiveRecord::Base
	belongs_to :user
end

class UserFollow <ActiveRecord::Base
	belongs_to :user
end