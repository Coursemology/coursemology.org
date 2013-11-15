class RemoveForemAdminFromUsers < ActiveRecord::Migration
  def up
    remove_column :users, :forem_admin
  end

  def down
    add_column :users, :forem_admin, :TINYINT
  end
end
