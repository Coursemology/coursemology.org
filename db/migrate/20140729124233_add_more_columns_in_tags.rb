class AddMoreColumnsInTags < ActiveRecord::Migration
  def up
    add_column :tags, :description, :text
    add_column :tags, :course_id, :integer
    add_column :tags, :tag_group_id, :integer
    add_column :tags, :deleted_at, :datetime
    add_column :tags, :created_at, :datetime
    add_column :tags, :updated_at, :datetime

    add_index :tags, :tag_group_id
  end

  def down
  end
end
