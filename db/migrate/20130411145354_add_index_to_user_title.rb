class AddIndexToUserTitle < ActiveRecord::Migration
  def change
    add_index :user_titles, :user_course_id
    add_index :user_titles, :title_id
  end
end
