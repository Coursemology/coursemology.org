class AddIndexToUser < ActiveRecord::Migration
  def change
    add_index :users, :system_role_id
  end
end
