class AddIndexToAnnotation < ActiveRecord::Migration
  def change
    add_index :annotations, :user_course_id
    add_index :annotations, :annotable_id
  end
end
