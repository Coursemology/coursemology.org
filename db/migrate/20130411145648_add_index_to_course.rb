class AddIndexToCourse < ActiveRecord::Migration
  def change
    add_index :courses, :creator_id
  end
end
