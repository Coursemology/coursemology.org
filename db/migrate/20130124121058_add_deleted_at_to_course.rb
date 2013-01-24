class AddDeletedAtToCourse < ActiveRecord::Migration
  def change
    add_column :courses, :deleted_at, :time
  end
end
