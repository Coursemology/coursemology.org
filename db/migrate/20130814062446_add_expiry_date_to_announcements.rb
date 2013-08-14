class AddExpiryDateToAnnouncements < ActiveRecord::Migration
  def change
    add_column :announcements, :expiry_at, :datetime
  end
end
