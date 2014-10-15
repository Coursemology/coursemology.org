class AddRewardableToExpTransaction < ActiveRecord::Migration
  def change
    add_column :exp_transactions, :rewardable_id, :integer
    add_column :exp_transactions, :rewardable_type, :string

    add_index :exp_transactions, [:rewardable_id, :rewardable_type]
  end
end
