class AddIndexToQuiz < ActiveRecord::Migration
  def change
    add_index :quizzes, :course_id
    add_index :quizzes, :creator_id
  end
end
