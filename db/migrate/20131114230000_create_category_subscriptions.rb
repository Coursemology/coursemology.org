class CreateCategorySubscriptions < ActiveRecord::Migration
  def up
    create_table :forem_category_subscriptions do |t|
      t.integer :subscriber_id
      t.integer :category_id
    end

  end

  def down
    drop_table :forem_category_subscriptions
  end
end
