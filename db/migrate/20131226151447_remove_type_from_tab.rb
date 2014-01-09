class RemoveTypeFromTab < ActiveRecord::Migration
  def up
    remove_column :tabs, :type
  end

  def down
    add_column :tabs, :type, :string
  end
end
