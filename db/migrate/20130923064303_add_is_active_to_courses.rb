class AddIsActiveToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :is_active, :boolean, default: true
  end
end
