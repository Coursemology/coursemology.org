class AddDeletedAtToSubmission < ActiveRecord::Migration
  def change
    add_column :submissions, :deleted_at, :time
  end
end
