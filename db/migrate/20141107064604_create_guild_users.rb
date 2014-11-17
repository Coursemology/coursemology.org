class CreateGuildUsers < ActiveRecord::Migration
  def change
    create_table :guild_users do |t|
      t.integer :role_id
      t.references :user_course, index: true
      t.references :guild, index: true

      t.timestamps
    end
  end
end
