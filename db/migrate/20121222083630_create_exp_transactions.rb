class CreateExpTransactions < ActiveRecord::Migration
  def change
    create_table :exp_transactions do |t|
      t.integer :exp
      t.string :reason
      t.boolean :is_valid
      t.integer :user_course_id
      t.integer :giver_id

      t.timestamps
    end
  end
end
