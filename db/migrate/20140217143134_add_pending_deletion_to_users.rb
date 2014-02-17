class AddPendingDeletionToUsers < ActiveRecord::Migration
  def change
    add_column :users, :is_pending_deletion, :boolean, default: false
  end
end
