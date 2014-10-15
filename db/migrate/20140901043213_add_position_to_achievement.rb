class AddPositionToAchievement < ActiveRecord::Migration
  def change
    add_column :achievements, :position, :integer
  end
end
