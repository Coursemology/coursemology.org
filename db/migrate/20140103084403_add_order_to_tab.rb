class AddOrderToTab < ActiveRecord::Migration
  def change
    add_column :tabs, :order, :integer
  end
end
