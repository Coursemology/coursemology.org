class CreateUserTitles < ActiveRecord::Migration
  def change
    create_table :user_titles do |t|
      t.integer :user_id
      t.integer :title_id
      t.integer :is_using

      t.timestamps
    end
  end
end
