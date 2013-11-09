class RemoveForemStateFromUsers < ActiveRecord::Migration
  def up
    remove_column :users, :forem_state
  end

  def down
    add_column :users, :forem_state, :VARCHAR
  end
end
