class AddPosToAchievements < ActiveRecord::Migration
  def change
    add_column :achievements, :pos, :integer
  end
end
