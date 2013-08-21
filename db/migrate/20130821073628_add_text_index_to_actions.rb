class AddTextIndexToActions < ActiveRecord::Migration
  def change
    add_index :actions, :text
  end
end
