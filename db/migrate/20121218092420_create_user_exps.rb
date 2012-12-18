class CreateUserExps < ActiveRecord::Migration
  def change
    create_table :user_exps do |t|
      t.integer :exp
      t.integer :level_id
      t.integer :user_course_id

      t.timestamps
    end
  end
end
