class AddUserSystemRoleColumn < ActiveRecord::Migration
  def change
    add_column :users, :system_role_id, :integer
  end
end
