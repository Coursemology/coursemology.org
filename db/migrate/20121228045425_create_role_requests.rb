class CreateRoleRequests < ActiveRecord::Migration
  def change
    create_table :role_requests do |t|
      t.integer :user_id
      t.integer :role_id

      t.timestamps
    end
  end
end
