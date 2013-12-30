class AddOwnerTypeToTab < ActiveRecord::Migration
  def change
    add_column :tabs, :owner_type, :string, :null => false
  end
end
