class AddPendingDeletionToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :is_pending_deletion, :boolean, default: false
  end
end
