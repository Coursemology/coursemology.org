class AddisLoggedInToUsers < ActiveRecord::Migration
  def up
    add_column  :users, :is_logged_in, :boolean, default: true
  end

  def down
    remove_column :users, :is_logged_in
  end
end
