class AddIndexToComment < ActiveRecord::Migration
  def change
    add_index :comments, :user_course_id
    add_index :comments, :commentable_id
  end
end
