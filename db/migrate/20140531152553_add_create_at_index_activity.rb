class AddCreateAtIndexActivity < ActiveRecord::Migration
  def up
    add_index :activities, :created_at
  end

  def down
    remove_index :activities, :created_at
  end
end
