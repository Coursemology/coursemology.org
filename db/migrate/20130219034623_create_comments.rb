class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.integer :user_course_id
      t.text :text
      t.integer :commentable_id
      t.string :commentable_type

      t.timestamps
    end
  end
end
