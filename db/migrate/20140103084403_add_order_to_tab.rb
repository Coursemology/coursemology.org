class AddOrderToTab < ActiveRecord::Migration
  def change
    add_column :tabs, :pos, :integer
  end
end
