class CreateQuizzes < ActiveRecord::Migration
  def change
    create_table :quizzes do |t|
      t.integer :course_id
      t.string :title
      t.string :description
      t.integer :exp
      t.integer :max_grade
      t.datetime :open_at
      t.datetime :close_at
      t.integer :order
      t.integer :attempt_limit
      t.integer :creator_id

      t.timestamps
    end
  end
end
