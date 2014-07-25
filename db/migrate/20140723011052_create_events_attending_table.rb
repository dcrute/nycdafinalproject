class CreateEventsAttendingTable < ActiveRecord::Migration
  def change
  	create_table :event_attendees do |entry|
  		entry.integer :event_id
  		entry.integer :user_id
  	end
  end
end
