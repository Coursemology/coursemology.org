class AddPublishToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :is_publish, :boolean, default: true
  end
end
