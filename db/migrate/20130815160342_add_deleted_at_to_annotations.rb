class AddDeletedAtToAnnotations < ActiveRecord::Migration
  def change
    add_column :annotations, :deleted_at, :time
  end
end
