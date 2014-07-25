class CreateEventsTable < ActiveRecord::Migration
  def change
  	create_table :events do |entry|
  		entry.string :title
  		entry.string :description
  		entry.string :location
  		entry.datetime	:date_time
  		entry.integer	:user_id
  	end
  end
end
