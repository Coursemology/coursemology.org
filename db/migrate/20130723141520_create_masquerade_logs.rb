class CreateMasqueradeLogs < ActiveRecord::Migration
  def change
    create_table :masquerade_logs do |t|
      t.integer :by_user_id
      t.integer :as_user_id
      t.integer :action
      t.text :description

      t.timestamps
    end
  end
end
