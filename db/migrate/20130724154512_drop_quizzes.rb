class DropQuizzes < ActiveRecord::Migration
  def up
    drop_table :quizzes
  end

  def down
  end
end
