class AddDeletedAtToAchievement < ActiveRecord::Migration
  def change
    add_column :achievements, :deleted_at, :time
  end
end
