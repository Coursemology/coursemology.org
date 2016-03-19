class RemoveDeletedAtFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :deleted_at
  end
end
