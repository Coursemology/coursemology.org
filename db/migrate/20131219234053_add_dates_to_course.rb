class AddDatesToCourse < ActiveRecord::Migration
  def change
    add_column :courses, :start_at, :datetime
    add_column :courses, :end_at, :datetime
  end
end
