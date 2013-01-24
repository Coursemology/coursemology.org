class AddDeletedAtToTraining < ActiveRecord::Migration
  def change
    add_column :trainings, :deleted_at, :time
  end
end
