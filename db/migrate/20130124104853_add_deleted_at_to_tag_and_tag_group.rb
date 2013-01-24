class AddDeletedAtToTagAndTagGroup < ActiveRecord::Migration
  def change
    add_column :tags, :deleted_at, :time
    add_column :tag_groups, :deleted_at, :time
  end
end
