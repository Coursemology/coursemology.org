class AddDeletedAtToTabs < ActiveRecord::Migration
  def change
    add_column :tabs, :deleted_at, :datetime
  end
end
