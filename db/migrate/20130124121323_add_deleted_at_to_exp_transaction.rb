class AddDeletedAtToExpTransaction < ActiveRecord::Migration
  def change
    add_column :exp_transactions, :deleted_at, :time
  end
end
