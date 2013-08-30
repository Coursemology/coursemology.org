class AddPublishToMissions < ActiveRecord::Migration
  def change
    add_column :missions, :publish, :boolean, default: true
  end
end
