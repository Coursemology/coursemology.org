class AddPublishedToAchievements < ActiveRecord::Migration
  def change
    add_column :achievements, :published, :boolean, :default => true
  end
end
