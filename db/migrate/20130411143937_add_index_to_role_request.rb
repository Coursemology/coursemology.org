class AddIndexToRoleRequest < ActiveRecord::Migration
  def change
    add_index :role_requests, :user_id
    add_index :role_requests, :role_id
  end
end
