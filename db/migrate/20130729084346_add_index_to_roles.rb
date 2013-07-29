class AddIndexToRoles < ActiveRecord::Migration
  def change
    add_index :roles, :name
  end
end
