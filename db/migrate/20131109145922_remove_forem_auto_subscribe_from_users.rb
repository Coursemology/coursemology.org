class RemoveForemAutoSubscribeFromUsers < ActiveRecord::Migration
  def up
    remove_column :users, :forem_auto_subscribe
  end

  def down
    add_column :users, :forem_auto_subscribe, :TINYINT
  end
end
