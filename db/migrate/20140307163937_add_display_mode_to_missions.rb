class AddDisplayModeToMissions < ActiveRecord::Migration
  def change
    add_column :missions, :display_mode, :integer, default: 1
  end
end
